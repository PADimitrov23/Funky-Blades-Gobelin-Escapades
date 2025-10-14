extends CharacterBody3D


enum States {attack, idle, chase, die}

var state = States.idle
var hp = 15
var speed = 2
var acceleration = 5
var gravity = 10
var target = null
var is_player_in_chase_area = false

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@export var animationPlayer : AnimationPlayer

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity
	
	if state == States.idle:
		
		print("idle")
		velocity = Vector3.ZERO
		animationPlayer.play("Idle")
		
	elif state == States.chase:
		
		print("chase")
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		navAgent.target_position = target.global_position
		
		var direction = navAgent.get_next_path_position() - global_position
		direction= direction.normalized()
		
		velocity = velocity.lerp(direction * speed, acceleration * delta)
		animationPlayer.play("Walk")
		
	elif state == States.attack:
		
		print("punch")
		velocity = Vector3.ZERO
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		animationPlayer.play("Punch")
		
	elif state == States.die:
		
		velocity = Vector3.ZERO
		animationPlayer.play("Die")
		
	move_and_slide()

func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.has_method("player"):
		target = body
		is_player_in_chase_area = true
		state = States.chase

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.has_method("player"):
		target = null
		is_player_in_chase_area = false
		if state != States.attack:
			state = States.idle

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("player"):
		state = States.attack

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.has_method("player"):
		if is_player_in_chase_area:
			state = States.chase
		else:
			state = States.idle
