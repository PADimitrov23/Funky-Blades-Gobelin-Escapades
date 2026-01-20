extends Node
#region Player Stats
static var gold = 0
static var health = 100
#endregion

#region Wave Logic Variables
static var waveCounter: int = 1
static var gobelinsPerWave: Curve = load("res://data/gobelins_per_wave.tres")
static var gobelinsSpawned: int = 0
static var gobelinsKilled: int = 0
static var inWave: bool = false
#endregion

func startIntermission():
	$tavern/TavernDoorWorkability.unlock()

func startWave():
	pass
