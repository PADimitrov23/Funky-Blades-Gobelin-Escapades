extends Node3D

@export var enemy : PackedScene

static var gobelinsPerWave: Curve = load("res://data/gobelins_per_wave.tres")
static var gobelinsSpawned: int = 0
static var gobelinsMax

func spawnGobelins(waveCounter):
	gobelinsMax = gobelinsPerWave.sample(waveCounter)
	#insert the weighted picker
	

func _on_timer_timeout() -> void:
	var instance = enemy.instantiate()
	add_child(instance)
