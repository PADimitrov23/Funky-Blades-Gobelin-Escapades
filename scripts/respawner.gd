extends Node3D

@export var enemy : PackedScene


func _on_timer_timeout() -> void:
	var instance = enemy.instantiate()
	add_child(instance)
