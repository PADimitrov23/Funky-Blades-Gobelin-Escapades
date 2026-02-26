extends Node

class ThreadedLoader extends Node:
	var level_path: String
	var loading_screen: LoadingScreen
	
	@warning_ignore("shadowed_variable")
	func _init(level_path: String, loading_screen: LoadingScreen) -> void:
		self.level_path = level_path
		self.loading_screen = loading_screen
		ResourceLoader.load_threaded_request(level_path)
	
	var level_instantiated: bool = false
	var visual_progress: float = 0.0
	
	func _process(delta: float) -> void:
		if not level_instantiated:
			_check_status()
		
		visual_progress = lerpf(visual_progress, 1.0, delta * 2.5)
		loading_screen.set_progress(visual_progress)
	
	var status: ResourceLoader.ThreadLoadStatus
	func _check_status() -> void:
		status = ResourceLoader.load_threaded_get_status(level_path)
		if status == ResourceLoader.THREAD_LOAD_LOADED:
			LevelLoader._finish_loading(ResourceLoader.load_threaded_get(level_path))
			level_instantiated = true

var packed_loading_screen = preload("res://scenes/loading_screen.tscn")
var loading_screen: LoadingScreen
var loader: ThreadedLoader

func loadLevel(scene_path: String) -> void:
	_new_loading_screen()
	_new_loader(scene_path)

func _new_loading_screen() -> void:
	loading_screen = packed_loading_screen.instantiate()
	get_tree().root.add_child(loading_screen)

func _new_loader(level_path: String) -> void:
	loader = ThreadedLoader.new(level_path, loading_screen)
	add_child(loader)

func _finish_loading(packed_level: PackedScene) -> void:
	var tree: SceneTree = get_tree()
	
	tree.root.remove_child(loading_screen)
	tree.change_scene_to_packed(packed_level)
	await tree.scene_changed
	
	tree.root.add_child(loading_screen)
	if tree.current_scene.has_signal("loaded"):
		await tree.current_scene.loaded
	_free_resources()

func _free_resources():
	loader.queue_free()
	loading_screen.fade_out()
