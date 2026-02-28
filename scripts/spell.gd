@abstract
extends Node3D
class_name Spell

@export var speed: float = 10.0
@onready var collision_area: Area3D = $CollisionArea

var fired: bool = false
var direction: Vector3

@abstract func _on_collide(body: Node3D) -> void

@warning_ignore("shadowed_variable")
func shoot(direction: Vector3) -> void:
	if fired:
		return
	
	fired = true
	self.direction = direction
	set_process(true)
	collision_area.body_entered.connect(_on_collide)
	get_tree().create_timer(2.0).timeout.connect(queue_free)

func _ready() -> void:
	set_process(false)

func _process(delta: float) -> void:
	global_translate(direction * speed * delta)
