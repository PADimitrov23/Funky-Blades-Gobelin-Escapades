extends Control
class_name LoadingScreen

@onready var progress_bar = $ProgressBar
@onready var percentage_label = $Percentage

func _ready() -> void:
	create_tween().tween_property(self, "modulate:a", 1.0, 1.0)

func set_progress(progress: float) -> void:
	progress_bar.value = progress
	percentage_label.text = str(int(progress * 100)) + "%"

func fade_out() -> void:
	set_progress(1.0)
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	tween.tween_callback(queue_free)
