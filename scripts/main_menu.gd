extends Control

@onready var sfx_light_switch: AudioStreamPlayer2D = $SfxLightSwitch

var button_type = null

func _ready() -> void:
	$Transition/AnimationPlayer.play("fade_out")


func _on_start_button_pressed() -> void:
	button_type = "start"
	_play_cord_pull_animation()


func _on_options_button_pressed() -> void:
	button_type = "options"
	_play_cord_pull_animation()


func _on_quit_button_pressed() -> void:
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	button_type = "credits"
	_play_cord_pull_animation()


func _play_cord_pull_animation():
	$CordPullAnimation.play()
	
	# Play sound after 1.2 seconds
	await get_tree().create_timer(1.2).timeout
	$SfxLightSwitch.play()
	
	# Trigger fade transition at 1.26 seconds
	await get_tree().create_timer(0.06).timeout
	$Transition/FadeTimer.start()
	$Transition/AnimationPlayer.play("fade_in")
	
	# Pause animation at 1.282 seconds
	await get_tree().create_timer(0.022).timeout
	$CordPullAnimation.paused = true


func _on_fade_timer_timeout() -> void:
	if button_type == "start":
		get_tree().change_scene_to_file("res://scenes/objective_splash.tscn")
		
	elif button_type == "options":
		get_tree().change_scene_to_file("res://scenes/options.tscn")
		
	elif button_type == "credits":
		get_tree().change_scene_to_file("res://scenes/credits.tscn")
