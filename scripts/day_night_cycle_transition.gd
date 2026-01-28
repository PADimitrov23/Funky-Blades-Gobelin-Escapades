extends Node3D

var hold_time := 0.0
const HOLD_DURATION := 1.5
var player_in_area: bool = false

#region Node connects
@onready var ui_progress_bar: TextureProgressBar = $CanvasLayer/HoldPrompt/ProgressBar
@onready var switch_time: Label = $CanvasLayer/HoldPrompt/Label
@onready var anim_player: AnimationPlayer = $AnimationPlayer
#endregion

func _ready() -> void:
	if Global.is_day:
		anim_player.play("cycle_day_to_night")
		anim_player.seek(anim_player.current_animation_length, true)
		anim_player.stop()
	else:
		anim_player.play("cycle_night_to_day")
		anim_player.seek(anim_player.current_animation_length, true)
		anim_player.stop()

func _process(delta: float) -> void:
	if not player_in_area:
		return

	if anim_player.is_playing():
		return

	if Input.is_action_pressed("interact"):
		hold_time += delta

		if ui_progress_bar:
			ui_progress_bar.value = clamp((hold_time / HOLD_DURATION) * 100.0, 0.0, 100.0)

		if hold_time >= HOLD_DURATION:
			if Global.is_day:
				anim_player.play("cycle_day_to_night")
				Global.is_day = false
			else:
				anim_player.play("cycle_night_to_day")
				Global.is_day = true

			hold_time = 0.0
	else:
		hold_time = 0.0
		if ui_progress_bar:
			ui_progress_bar.value = 0.0

func _on_day_night_buttons_area_body_entered(body: Node3D) -> void:
	if body is Player:
		player_in_area = true
		if ui_progress_bar:
			ui_progress_bar.visible = true
			switch_time.visible = true

func _on_day_night_buttons_area_body_exited(body: Node3D) -> void:
	if body is Player:
		player_in_area = false
		hold_time = 0.0
		switch_time.visible = false
		
		if ui_progress_bar:
			ui_progress_bar.value = 0.0
			ui_progress_bar.visible = false
			switch_time.visible = false
