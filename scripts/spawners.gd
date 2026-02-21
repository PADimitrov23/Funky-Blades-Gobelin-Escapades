extends Node

var gobelinsPerWave: Curve = preload("res://data/gobelins_per_wave.tres")
var randomGobelinPicker: WeightedPicker = WeightedPicker.new(
	[preload("res://scenes/enemy.tscn")],
	[1]
)

func _ready() -> void:
	pass
	#startSpawning(1)

func startSpawning(wave: int) -> void:
	var tree: SceneTree = get_tree()
	var spawners: Array = tree.get_nodes_in_group("spawners")
	var gobelinsLeft = gobelinsPerWave.sample(wave)
	
	var gobelin: Enemy
	while gobelinsLeft > 0:
		await tree.create_timer(randf_range(0, 3)).timeout
		
		gobelin = randomGobelinPicker.pick().instantiate()
		gobelin.transform = spawners.pick_random().transform
		tree.current_scene.add_child(gobelin)
		gobelinsLeft -= 1
