extends Node

#region World control variables
var is_day: bool = true
#endregion

#region Player Stats
var gold = 0
var health = 100
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
	
