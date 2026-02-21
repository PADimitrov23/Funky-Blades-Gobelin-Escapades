extends Control


func _ready() -> void:
	$Transition/AnimationPlayer.play("fade_out")


func _on_back_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/main_menu.tscn")
