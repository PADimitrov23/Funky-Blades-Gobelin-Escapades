extends Control

@onready var slot1_zone: ItemDropZone = $VBoxContainer/EquationRow/Slot1/ItemDropZone
@onready var slot2_zone: ItemDropZone = $VBoxContainer/EquationRow/Slot2/ItemDropZone
@onready var elements_grid: GridContainer = $VBoxContainer/InventoryArea/ElementsGrid
@onready var combine_button: Button = $VBoxContainer/ControlRow/CombineButton
@onready var result_text: Label = $VBoxContainer/ControlRow/ResultText
@onready var tempest_sprite: AnimatedSprite2D = $VBoxContainer/EquationRow/ResultSlot/TempestBurst
@onready var salt_sprite: AnimatedSprite2D = $VBoxContainer/EquationRow/ResultSlot/SaltPrison

var player: Player = null
var inventory_rest_zones: Dictionary = {}

func _ready() -> void:
	await get_tree().current_scene.ready
	player = get_tree().current_scene.get_node("Player")
	
	await get_tree().process_frame
	
	for child in elements_grid.get_children():
		if child is DraggableItem:
			var initial_zone = ItemDropZone.new()
			initial_zone.global_position = child.global_position
			child.rest_zone = initial_zone
			initial_zone.register_item(child)
			inventory_rest_zones[child.name] = initial_zone
	
	combine_button.pressed.connect(_on_combine_pressed)
	visibility_changed.connect(_on_visibility_changed)


func _on_visibility_changed() -> void:
	Global.chemistry_ui_active = visible
	if visible:
		result_text.text = "Ready"
		_hide_all_outcomes()
		tempest_sprite.scale = Vector2.ONE
		salt_sprite.scale = Vector2.ONE


func _hide_all_outcomes() -> void:
	tempest_sprite.visible = false
	salt_sprite.visible = false


func _on_combine_pressed() -> void:
	if slot1_zone.item == null or slot2_zone.item == null:
		result_text.text = "Need 2 elements!"
		return
	
	var element1 = slot1_zone.item.element_type
	var element2 = slot2_zone.item.element_type
	
	var elements = [element1, element2]
	elements.sort()
	var combination = "_".join(elements)
	
	_hide_all_outcomes()
	
	match combination:
		"chlorine_sodium":
			result_text.text = "Salt Prison!"
			salt_sprite.visible = true
			_show_effect(salt_sprite)
			_trigger_salt_prison()
		"sodium_water":
			result_text.text = "Tempest Burst!"
			tempest_sprite.visible = true
			_show_effect(tempest_sprite)
			_trigger_tempest_burst()
		"chlorine_water":
			result_text.text = "Water fizzles..."
			_trigger_water_fizzle()
		_:
			result_text.text = "No reaction"


func _show_effect(sprite: AnimatedSprite2D) -> void:
	sprite.visible = true
	sprite.play("default")
	sprite.modulate = Color(1, 1, 1, 0)
	sprite.scale = Vector2(0.5, 0.5)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color.WHITE, 0.5)
	tween.tween_property(sprite, "scale", Vector2.ONE, 0.5).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	
	await tween.finished
	await get_tree().create_timer(1.0).timeout
	_close_menu()


func _close_menu() -> void:
	Global.chemistry_ui_active = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	_reset_items_to_inventory()
	var parent_control = get_parent()
	if parent_control:
		parent_control.visible = false


func _reset_items_to_inventory() -> void:
	if slot1_zone.item:
		var item1 = slot1_zone.item
		var original_rest = inventory_rest_zones.get(item1.name)
		slot1_zone.deregister_item()
		if original_rest:
			item1.rest_zone = original_rest
			original_rest.register_item(item1)
	
	if slot2_zone.item:
		var item2 = slot2_zone.item
		var original_rest = inventory_rest_zones.get(item2.name)
		slot2_zone.deregister_item()
		if original_rest:
			item2.rest_zone = original_rest
			original_rest.register_item(item2)


func _trigger_tempest_burst() -> void:
	if player:
		player.set_spell(preload("res://scenes/spells/tempest_burst.tscn"))
	_clear_slots()


func _trigger_water_fizzle() -> void:
	_clear_slots()
	await get_tree().create_timer(1.0).timeout
	_close_menu()


func _trigger_salt_prison() -> void:
	if player:
		player.set_spell(preload("res://scenes/spells/salt_prison.tscn"))
	_clear_slots()


func _clear_slots() -> void:
	pass
