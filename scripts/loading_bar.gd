extends Control

#region exports
@onready var loading_bar: ProgressBar = $progress_bar
@onready var percentage_label: Label = $percentage_label
#endregion

var scenePath = Global.goToScene
var progress := []
var visualProgress := 0.0
var loadingDone := false
var transitioning := false
var finished = false

func _ready():
	ResourceLoader.load_threaded_request(scenePath)

func _process(delta):
	var status = ResourceLoader.load_threaded_get_status(scenePath, progress)

	if status == ResourceLoader.THREAD_LOAD_LOADED:
		loadingDone = true

	var target = 1.0 if loadingDone else 0.9
	visualProgress = lerp(visualProgress, target, delta * 2.5)

	loading_bar.value = visualProgress
	percentage_label.text = str(int(visualProgress * 100)) + "%"
	
	if loadingDone and visualProgress >= 0.99 and not transitioning:
		transitioning = true
		get_tree().change_scene_to_packed(ResourceLoader.load_threaded_get(scenePath))
	
