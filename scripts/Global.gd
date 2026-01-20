extends Node
#region Player Stats
static var gold = 0
static var health = 100
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
	 
	
