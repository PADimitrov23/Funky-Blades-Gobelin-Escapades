extends Node
#region Player Stats
var gold = 0
var health = 100
#endregion

#region Wave Logic Variables
var waveCounter: int = 1
var gobelinsSpawned: int = 0
var gobelinsKilled: int = 0
var inWave: bool = false
#endregion

func startIntermission():
	$tavern/TavernDoorWorkability.unlock()

func startWave():
	pass
