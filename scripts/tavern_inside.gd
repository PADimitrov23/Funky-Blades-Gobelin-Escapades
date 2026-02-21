extends Node3D


func _ready() -> void:
	$Transition/AnimationPlayer.play("fade_out")


func _process(delta: float) -> void:
	pass
