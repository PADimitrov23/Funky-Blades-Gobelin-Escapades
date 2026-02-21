extends Control
@onready var sfx_light_switch: AudioStreamPlayer2D = $ColorRect/TextSfxButton/TestSfxPlayer

func _ready() -> void:
	$Transition/AnimationPlayer.play("fade_out")


func _on_back_button_pressed() -> void:
	$Transition/AnimationPlayer.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_accept_button_pressed() -> void:
	$Transition/AnimationPlayer.play("fade_in")
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")


func _on_text_sfx_button_pressed() -> void:
	$ColorRect/TextSfxButton/TestSfxPlayer.play()
