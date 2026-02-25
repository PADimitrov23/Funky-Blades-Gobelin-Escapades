extends Control
 
#region exports
@onready var loading_bar: ProgressBar = $progress_bar
@onready var percentage_label: Label = $percentage_label
@onready var anim_player: AnimationPlayer = $Transition/AnimationPlayer
#endregion 

#region variables
var scenePath = Global.goToScene
var progress := []
var visualProgress := 0.0
var loadingDone := false
var transitioning := false
var world_instance
var scatter_finished := false
#endregion

func _ready():
	ResourceLoader.load_threaded_request(scenePath)
 
func _process(delta):
	var status = ResourceLoader.load_threaded_get_status(scenePath, progress)
	if status == ResourceLoader.THREAD_LOAD_LOADED and not loadingDone:
		loadingDone = true
		if (scenePath == "res://scenes/world.tscn"):
			_spawn_world()
		else:
			scatter_finished = true
	
	var target = 1.0 if scatter_finished else 0.9
	visualProgress = lerp(visualProgress, target, delta * 2.5)
	loading_bar.value = visualProgress
	percentage_label.text = str(int(visualProgress * 100)) + "%"
	if scatter_finished and visualProgress >= 0.99 and not transitioning:
		transitioning = true
		await _finish_transition()
 
func _spawn_world():
	var packed_scene = ResourceLoader.load_threaded_get(scenePath)
	world_instance = packed_scene.instantiate()
	get_tree().root.add_child(world_instance)
	get_tree().current_scene = world_instance
	var grass = world_instance.get_node("bushes_proton")
	grass.build_completed.connect(_on_scatter_done)

func _on_scatter_done():
	scatter_finished = true
  
func _finish_transition():
	anim_player.play("fade_out")
	await anim_player.animation_finished
	queue_free() # remove loading screen
 
