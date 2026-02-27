class_name DraggableItem
extends AnimatedSprite2D

@export var rest_zone: ItemDropZone = null
@export var element_type: String = ""
var selected: bool = false
var rest_zones: Array

func _ready() -> void:
	rest_zones = get_tree().get_nodes_in_group("drop_zone")


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var mouse_pos = get_global_mouse_position()
		var distance = global_position.distance_to(mouse_pos)
		
		if distance < 60:
			if event.is_pressed():
				selected = true
			elif selected:
				selected = false
				
				if rest_zone == null:
					return
					
				var old_rest_zone = rest_zone
				old_rest_zone.deregister_item()
				
				if rest_zones.size() == 0:
					rest_zone = old_rest_zone
					old_rest_zone.register_item(self)
					return
					
				var shortest_distance = global_position.distance_to(rest_zones[0].global_position)
				for zone in rest_zones:
					var distance_to_zone = global_position.distance_to(zone.global_position)
					if distance_to_zone <= shortest_distance:
						rest_zone = zone
						shortest_distance = distance_to_zone
				
				if rest_zone.item != null:
					rest_zone.swap(self, old_rest_zone)
				else:
					rest_zone.register_item(self)


func _physics_process(delta: float) -> void:
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25 * delta)
	elif rest_zone != null:
		global_position = lerp(global_position, rest_zone.global_position, 10 * delta)
		global_position = lerp(global_position, rest_zone.global_position, 10 * delta)
