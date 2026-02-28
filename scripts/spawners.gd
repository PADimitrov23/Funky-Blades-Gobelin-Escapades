extends Node

var gobelinsPerWave: Curve = preload("res://data/gobelins_per_wave.tres")
var currentWaveSample = gobelinsPerWave.sample(Global.waveCounter)
var gobelinsKilled = 0

var randomGobelinPicker: WeightedPicker = WeightedPicker.new(
	[preload("res://scenes/enemy.tscn"),
	 preload("res://scenes/enemy_heavy.tscn"),
	 preload("res://scenes/enemy_mage.tscn")],
	[3, 1, 2]
)

func _ready() -> void:
	pass

func start_spawning(_wave: int) -> void:
	var tree: SceneTree = get_tree()
	var spawners: Array = tree.get_nodes_in_group("spawners")
	currentWaveSample = gobelinsPerWave.sample(Global.waveCounter)
	var gobelinsLeft = currentWaveSample
	
	#WAVE STARTED TEXT
	await tree.create_timer(12).timeout
	#WAVE STARTED TEXT DISSAPEARED
	
	var gobelin: Enemy
	while gobelinsLeft > 0:
		await tree.create_timer(randf_range(0, 3)).timeout
		
		gobelin = randomGobelinPicker.pick().instantiate()
		gobelin.died.connect(on_gobelin_death)
		gobelin.transform = spawners.pick_random().transform
		tree.current_scene.add_child(gobelin)
		gobelinsLeft -= 1

func on_gobelin_death():
	gobelinsKilled += 1
	if gobelinsKilled >= currentWaveSample:
		var environmentSwitcherNode = get_tree().current_scene.get_node("day_night_cycle_transition")
		#WAVE ENDED TEXT
		await get_tree().create_timer(6).timeout
		#WAVE ENDED TEXT DISSAPEARED
		environmentSwitcherNode.switch_to_day()
		Global.start_intermission()
