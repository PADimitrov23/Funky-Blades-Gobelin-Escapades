extends Node

var gobelinsPerWave: Curve = preload("res://data/gobelins_per_wave.tres")
var gobelinsKilled := 0

var randomGobelinPicker: WeightedPicker = WeightedPicker.new(
	[preload("res://scenes/enemy.tscn"),
	 preload("res://scenes/enemy_heavy.tscn"),
	 preload("res://scenes/enemy_mage.tscn")],
	[3, 1, 2]
)

func _ready() -> void:
	pass

func start_spawning(wave: int) -> void:
	var tree: SceneTree = get_tree()
	var spawners: Array = tree.get_nodes_in_group("spawners")
	var currentWaveSample = gobelinsPerWave.sample(wave)
	var gobelinsLeft = currentWaveSample
	
	var gobelin: Enemy = randomGobelinPicker.pick().instantiate()
	gobelin.transform = spawners.pick_random().transform
	
	while gobelinsLeft > 0:
		await tree.create_timer(randf_range(0, 3)).timeout
		
		gobelin = randomGobelinPicker.pick().instantiate()
		gobelin.died.connect(on_gobelin_death)
		gobelin.transform = spawners.pick_random().transform
		tree.current_scene.add_child(gobelin)
		gobelinsLeft -= 1
		if gobelinsKilled >= currentWaveSample:
			var environmentSwitcherNode = get_node("day_night_cycle_transition")
			environmentSwitcherNode.switch_to_day()
			Global.start_intermission()
			break

func on_gobelin_death():
	gobelinsKilled += 1
