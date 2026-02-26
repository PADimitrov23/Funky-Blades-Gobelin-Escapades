extends Control

@onready var transition = $Transition/AnimationPlayer

func _ready() -> void:
	transition.play("fade_out")
	await transition.animation_finished
	$Timer.start()

func _on_timer_timeout() -> void:
	transition.play("fade_in")
	await transition.animation_finished
	LevelLoader.loadLevel("res://scenes/world.tscn")
