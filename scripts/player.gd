extends CharacterBody3D
class_name Player

#region Movement variables
@export var move_speed := 5.0
@export var sprint_speed := 11.0
@export var acceleration := 12.0
@export var air_control := 0.6
@export var jump_force := 8.0
@export var gravity := 24.0
@export var sensitivity := 0.001
@export var slide_speed := 22.0
@export var slide_decay := 1.0
@export var camera_tilt := 5.0
#endregion

#region Player stats
var gold := 0
var health := 100
var max_health := 100
var damage := 10
var target := []
#endregion

#region Player states
var velocity_y := 0.0
var move_dir := Vector3.ZERO
var input_dir := Vector3.ZERO
var sliding := false
var current_speed := 0.0
var rotation_x := 0.0
#endregion

#region Node connects
@onready var first_person_camera: Camera3D = $FirstPerson
@onready var third_person_camera: Camera3D = $Head/ThirdPerson
@onready var camera: Camera3D = first_person_camera
@onready var animationPlayer = $SwordAnimations
@onready var attackCooldown = $AttackCooldown
@onready var inspectCooldown = $InspectCooldown
@onready var healthBar = $HUD/HealthBar
@onready var goldCounter = $HUD/GoldCounter
#endregion

func _ready():
	healthBar.max_value = max_health
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

#Input and camera handling
func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func _switch_view():
	if Input.is_action_just_pressed("switch_view"):
		if camera == first_person_camera:
			first_person_camera.current = false
			third_person_camera.current = true
			camera = third_person_camera
		else:
			third_person_camera.current = false
			first_person_camera.current = true
			camera = first_person_camera

func attack():
	if Input.is_action_just_pressed("attack") and attackCooldown.is_stopped():
		animationPlayer.play("SwordSwing")
		attackCooldown.start()

func deal_damage():
	for enemy in target:
		if enemy and enemy.is_inside_tree():
			enemy.take_damage(damage)

func inspect():
	if Input.is_action_just_pressed("inspect") and inspectCooldown.is_stopped():
		animationPlayer.play("SwordInspect")
		inspectCooldown.start()

func update_HUD():
	healthBar.value = health
	goldCounter.text = str(gold)

func _process(_delta):
	attack()
	inspect()
	_switch_view()
	update_HUD()
	if Input.is_action_just_pressed("escape"):
		get_tree().quit()

func _physics_process(delta):
	
	var speed := velocity.length()
	var density := 0.0

	if speed >= 10:
		density = 1.0
	elif speed >= 8:
		density = 0.8
	elif speed >= 6:
		density = 0.6
	elif speed >= 4:
		density = 0.4
	elif speed >= 2:
		density = 0.2

	$Speedlines.material.set_shader_parameter("line_density", density)
	
	floor_snap_length = 0.3
	
	var input_vec := Input.get_vector("left", "right", "up", "down")
	input_dir = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()

	var target_speed = move_speed
	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed

	# Smooth acceleration + air control
	var control := 1.0 if is_on_floor() else air_control
	if input_dir != Vector3.ZERO:
		move_dir = move_dir.lerp(input_dir * target_speed, acceleration * control * delta)
	else:
		move_dir = move_dir.lerp(Vector3.ZERO, acceleration * delta)

	# Gravity + jump
	if not is_on_floor():
		velocity_y -= gravity * delta
	elif not sliding:
		if Input.is_action_just_pressed("jump"):
			velocity_y = jump_force

	# Start / stop slide
	if Input.is_action_just_pressed("crouch") and is_on_floor() and not sliding:
		_start_slide()
	elif Input.is_action_just_released("crouch") and sliding:
		_end_slide()

	# Handle sliding
	if sliding:
		move_dir = move_dir.lerp(Vector3.ZERO, slide_decay * delta)
		velocity_y = -3.0  # keeps player pushed into the ground
		if move_dir.length() < move_speed:
			_end_slide()

	# Combine
	velocity = move_dir + Vector3.UP * velocity_y

	# Stick to ground during slide
	floor_snap_length = 0.3 if is_on_floor() else 0.0

	move_and_slide()

	# --- Camera effects ---
	var target_tilt = -input_vec.x * camera_tilt
	camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, target_tilt, 10 * delta)

	# FOV widen during slide
	if camera is Camera3D:
		var target_fov = 90.0 if sliding else 75.0
		camera.fov = lerp(camera.fov, target_fov, 5 * delta)

func _start_slide():
	sliding = true
	move_dir = move_dir.normalized() * slide_speed
	velocity_y = -3.0  # pushes player down to stay grounded

func _end_slide():
	sliding = false

func _on_attack_cooldown_timeout() -> void:
	pass

func _on_inspect_cooldown_timeout() -> void:
	pass 

func _on_attack_zone_body_entered(body: Node3D) -> void:
	if body is Enemy and body != self:
		print("Enemy entered: ", body.name)
		target.append(body)

func _on_attack_zone_body_exited(body: Node3D) -> void:
	if body is Enemy:
		target.erase(body)
