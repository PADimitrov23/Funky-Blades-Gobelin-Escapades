extends CharacterBody3D
class_name Enemy

enum States {attack, idle, chase, die}

var state = States.idle
var damage = 10
var health = 15
var speed = 2
var acceleration = 5
var gravity = 10
var target = null
var gold = 1

@onready var hit_particles: Node3D = $Gobelin/hitMarker
@onready var navAgent: NavigationAgent3D = $NavigationAgent3D
@export var animationPlayer: AnimationPlayer

func _process(_delta: float) -> void:
	pass

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity.y -= gravity
	
	if state == States.idle:
		
		velocity = Vector3(0, velocity.y, 0)
		animationPlayer.play("Idle")
		
	elif state == States.chase:
		
		look_at(Vector3(target.global_position.x, global_position.y, target.global_position.z), Vector3.UP, true)
		navAgent.target_position = target.global_position
		
		var direction = navAgent.get_next_path_position() - global_position
		direction = direction.normalized()
		
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

func play_hit_particles():
	for child in hit_particles.get_children():
		if child is GPUParticles3D:
			child.restart()

func take_damage(amount):
	health -= amount
	play_hit_particles()
	
	if health <= 0:
		state = States.die

func attack():
	target.health -= damage

func drop_loot():
	target.gold += gold

func _on_chase_area_body_entered(body: Node3D) -> void:
	if body is Player and state != States.die:
		target = body
		state = States.chase

func _on_chase_area_body_exited(body: Node3D) -> void:
	if body is Player and state != States.die:
		target = null
		state = States.idle

func _on_attack_area_body_entered(body: Node3D) -> void:
	if body is Player and state != States.die:
		state = States.attack

func _on_attack_area_body_exited(body: Node3D) -> void:
	if body is Player and state != States.die:
		state = States.chase
