extends Control

#region exports
@onready var gold_label: Label = $PanelContainer/VBoxContainer/Header/GoldLabel
@onready var health_potion_btn: Button = $PanelContainer/VBoxContainer/ItemList/HealthPotionBtn
@onready var speed_potion_btn: Button = $PanelContainer/VBoxContainer/ItemList/SpeedPotionBtn
@onready var strength_potion_btn: Button = $PanelContainer/VBoxContainer/ItemList/StrengthPotionBtn
@onready var jump_potion_btn: Button = $PanelContainer/VBoxContainer/ItemList/JumpPotionBtn
@onready var feedback_label: Label = $PanelContainer/VBoxContainer/FeedbackLabel
@onready var feedback_timer: Timer = $FeedbackTimer
#endregion

#region variables
var is_open: bool = false
var shopItems := {
	"health_potion": {
		"name": "Health Potion",
		"description": "Restores 30 HP",
		"cost": 5,
		"effect": "health",
		"amount": 30
	},
	"strength_potion": {
		"name": "Strength Potion",
		"description": "+2 Permanent Damage",
		"cost": 10,
		"effect": "strength",
		"amount": 2
	},
	"speed_potion": {
		"name": "Speed Potion",
		"description": "+2 Permanent Speed",
		"cost": 10,
		"effect": "speed",
		"amount": 2
	},
	"jump_potion": {
		"name": "Jump Potion",
		"description": "+2 Permanent Jump Height",
		"cost": 10,
		"effect": "jump",
		"amount": 1
	}
}
#endregion

func _ready():
	visible = false
	_update_gold_display()
	_update_button_labels()

func _update_gold_display():
	gold_label.text = "Gold: " + str(Global.gold)

func _update_button_labels():
	var hp_item = shopItems["health_potion"]
	var st_item = shopItems["strength_potion"]
	var sp_item = shopItems["speed_potion"]
	var jm_item = shopItems["jump_potion"]
	health_potion_btn.text = hp_item["name"] + " - " + str(hp_item["cost"]) + "g (" + hp_item["description"] + ")"
	strength_potion_btn.text = st_item["name"] + " - " + str(st_item["cost"]) + "g (" + st_item["description"] + ")"
	speed_potion_btn.text = sp_item["name"] + " - " + str(sp_item["cost"]) + "g (" + sp_item["description"] + ")"
	jump_potion_btn.text = jm_item["name"] + " - " + str(jm_item["cost"]) + "g (" + jm_item["description"] + ")"

func open_shop():
	if is_open:
		return
	is_open = true
	visible = true
	_update_gold_display()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func close_shop():
	if not is_open:
		return
	is_open = false
	visible = false
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _show_feedback(msg: String):
	feedback_label.text = msg
	feedback_label.visible = true
	feedback_timer.start()

func _on_feedback_timer_timeout():
	feedback_label.visible = false
	feedback_label.text = ""

func _on_health_potion_btn_pressed():
	if Global.gold >= shopItems.health_potion.cost:
		_show_feedback("Purchased Health Potion! HP: " + str(Global.health) + "/" + str(Global.health))
		Global.health += 30
		Global.gold -= shopItems.health_potion.cost
	else:
		_show_feedback("Not enough gold!")
	_update_gold_display()

func _on_strength_potion_btn_pressed() -> void:
	if Global.gold >= shopItems.strength_potion.cost:
		_show_feedback("Purchased Strength Potion! Strength: UP +2")
		Global.damage += 2
		Global.gold -= shopItems.strength_potion.cost
	else:
		_show_feedback("Not enough gold!")
	_update_gold_display()

func _on_speed_potion_btn_pressed() -> void:
	if Global.gold >= shopItems.speed_potion.cost:
		_show_feedback("Purchased Speed Potion! Speed: UP +2")
		Global.sprint_speed += 1
		Global.move_speed += 1
		Global.gold -= shopItems.speed_potion.cost
	else:
		_show_feedback("Not enough gold!")
	_update_gold_display()

func _on_jump_potion_btn_pressed() -> void:
	if Global.gold >= shopItems.jump_potion.cost:
		_show_feedback("Purchased Speed Potion! Jump Height: UP +1")
		Global.jump_force += 1
		Global.gold -= shopItems.jump_potion.cost
	else:
		_show_feedback("Not enough gold!")
	_update_gold_display()

func _process(_delta):
	if is_open and Input.is_action_just_pressed("escape"):
		close_shop()

func _on_shop_area_body_entered(body: Node3D) -> void:
	if body is Player:
		open_shop()

func _on_shop_area_body_exited(body: Node3D) -> void:
	if body is Player:
		close_shop()
