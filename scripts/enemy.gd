extends CharacterBody3D


enum States {attack, idle, chase, die}

var state = States.idle
var damage = 10
var health = 15
var speed = 2
var acceleration = 5
var gravity = 10
var target = null
var is_player_in_chase_area = false
var value = 1

@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@export var animationPlayer : AnimationPlayer

func enemy():
	pass

func _process(delta):
	if health <= 0:
		state = States.die

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity
	
	if state == States.idle:
		
		velocity = Vector3.ZERO
		animationPlayer.play("Idle")
		
	elif state == States.chase:
		
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		navAgent.target_position = target.global_position
		
		var direction = navAgent.get_next_path_position() - global_position
		direction= direction.normalized()
		
		velocity = velocity.lerp(direction * speed, acceleration * delta)
		animationPlayer.play("Walk")
		
	elif state == States.attack:
		
		velocity = Vector3.ZERO
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		animationPlayer.play("Punch")
		
	elif state == States.die:
		
		velocity = Vector3.ZERO
		animationPlayer.play("Die")
		
	move_and_slide()

func attack():
	target.health -= damage

func drop_loot():
	target.gold += value

func _on_chase_area_body_entered(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		target = body
		is_player_in_chase_area = true
		state = States.chase

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		target = null
		is_player_in_chase_area = false
		if state != States.attack:
			state = States.idle

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		state = States.attack

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body.has_method("player") and state != States.die:
		if is_player_in_chase_area:
			state = States.chase
		else:
			state = States.idle
