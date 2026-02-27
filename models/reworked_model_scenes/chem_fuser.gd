extends Node3D

#region variables
var locked: bool = false
var player_in_area: bool = false
#endregion

#region exports
@onready var locked_label: Label = $CanvasLayer/LockedPrompt/Label
#endregion

func unlock():
	locked = false

func lock():
	locked = true

func _ready() -> void:
	if not $RootNode/Area3D.body_entered.is_connected(_on_area_3d_body_entered):
		$RootNode/Area3D.body_entered.connect(_on_area_3d_body_entered)
	if not $RootNode/Area3D.body_exited.is_connected(_on_area_3d_body_exited):
		$RootNode/Area3D.body_exited.connect(_on_area_3d_body_exited)


func _process(_delta: float) -> void:
	pass


func _on_area_3d_body_entered(body: Node3D) -> void:
	if body.name == "Player" or body is Player:
		player_in_area = true
		if locked:
			if locked_label:
				locked_label.visible = true
			return
		$chemMenu.visible = true
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _on_area_3d_body_exited(body: Node3D) -> void:
	if body.name == "Player" or body is Player:
		player_in_area = false
		$chemMenu.visible = false
		Global.chemistry_ui_active = false
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		if locked_label:
			locked_label.visible = false
