extends Node3D

#region variables
var locked: bool = false
var load_in_progress: bool = false
var player_in_area: bool = false
var hold_time := 0.0
const HOLD_DURATION := 1.5
#endregion

#region exports
@export_file() var target_level: String
@onready var ui_progress_bar: TextureProgressBar = $CanvasLayer/HoldPrompt/ProgressBar
@onready var door_is_locked_text: Label = $CanvasLayer/HoldPrompt/Label
#endregion

func unlock():
	locked = false

func lock():
	locked = true

func _on_area_3d_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_area = true
		if ui_progress_bar:
			ui_progress_bar.visible = true
		if locked:
			door_is_locked_text.visible = true

func _on_area_3d_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_area = false
		hold_time = 0.0
		door_is_locked_text.visible = false
		
		if ui_progress_bar:
			ui_progress_bar.value = 0.0
			ui_progress_bar.visible = false

func _process(delta):
	if not player_in_area or locked or load_in_progress:
		return
	
	if Input.is_action_pressed("interact"):
		hold_time += delta
		if ui_progress_bar:
			ui_progress_bar.value = clamp((hold_time / HOLD_DURATION) * 100.0, 0.0, 100.0)

		if hold_time >= HOLD_DURATION:
			load_in_progress = true
			LevelLoader.loadLevel(target_level)
	else:
		hold_time = 0.0
		if ui_progress_bar:
			ui_progress_bar.value = 0.0
