extends Control

var button_type = null                                                                                                        

func _ready() -> void:
	$Transition/AnimationPlayer.play("fade_out")


func _on_start_button_pressed() -> void:
	button_type = "start"
	$Transition/AnimationPlayer.play("fade_in")
	await $Transition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/objective_splash.tscn")


func _on_options_button_pressed() -> void:
	button_type = "options"
	$Transition/AnimationPlayer.play("fade_in")
	await $Transition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/options.tscn")


func _on_quit_button_pressed() -> void:
	$Transition/AnimationPlayer.play("fade_in")
	await $Transition/AnimationPlayer.animation_finished
	get_tree().quit()

func _on_credits_button_pressed() -> void:
	button_type = "credits"
	$Transition/AnimationPlayer.play("fade_in")
	await $Transition/AnimationPlayer.animation_finished
	get_tree().change_scene_to_file("res://scenes/credits.tscn")
