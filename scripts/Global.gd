extends Node

var is_day: bool = true
var chemistry_ui_active: bool = false

var gold = 0
var health := 100
var damage := 10
var move_speed := 5.0
var sprint_speed := 11.0
var jump_force := 8.0
var goToScene := "res://scenes/world.tscn"
#endregion

#region Wave Logic Variables
static var waveCounter: int = 1
static var inWave: bool = false
#endregion

func start_intermission():
	inWave = false
	pass

func start_wave():
	inWave = true
	Spawners.start_spawning(waveCounter)
	
