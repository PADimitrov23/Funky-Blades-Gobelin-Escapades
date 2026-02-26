extends Node

#region World control variables
var is_day: bool = true
#endregion

#region Player Stats
var gold = 0
var health := 100
var damage : int
var move_speed := 5.0
var sprint_speed := 11.0
var jump_force := 8.0
var goToScene := "res://scenes/world.tscn"
#endregion

#region Wave Logic Variables
static var waveCounter: int = 1
static var inWave: bool = false
#endregion

func startIntermission():
	$tavern/TavernDoorWorkability.unlock()

func startWave():
	$tavern/TavernDoorWorkability.lock()
	#THE SKY CHANGES AND THERES A TEXT MESSAGE
	 
	
