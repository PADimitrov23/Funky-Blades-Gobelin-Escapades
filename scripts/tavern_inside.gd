extends Node3D


func _ready() -> void:
	$Transition/AnimationPlayer.play("fade_out")


func _process(_delta: float) -> void:
	pass
