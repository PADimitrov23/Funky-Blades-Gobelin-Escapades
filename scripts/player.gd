extends CharacterBody3D
class_name Player

#region Movement variables
@export var move_speed := Global.move_speed 
@export var sprint_speed = Global.sprint_speed
@export var acceleration = 12.0
@export var air_control := 0.6
@export var jump_force = Global.jump_force
@export var gravity := 24.0
@export var sensitivity := 0.001
@export var slide_speed := 22.0
@export var slide_decay := 1.0
@export var camera_tilt := 5.0
#endregion

#region Player stats
var gold = Global.gold
var health = Global.health
var stamina = 100
var maxHealth := 100
var maxStamina := 100
var damage = Global.damage
var target := []
var current_spell: Spell
var packed_spell: PackedScene
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
@onready var spell_handle: Node3D = $FirstPerson/SpellHandle
@onready var spell_cooldown: Timer = $SpellCooldown
@onready var attack_cooldown = $AttackCooldown
@onready var slide_cooldown = $SlideCooldown
@onready var inspect_cooldown = $InspectCooldown
@onready var healthBar = $HUD/HealthBar
@onready var goldCounter = $HUD/GoldCounter
@onready var staminaBar = $HUD/StaminaBar
#endregion

# available spells?
func set_spell(spell: PackedScene) -> void:
	if current_spell:
		current_spell.queue_free()
	
	packed_spell = spell
	_respawn_spell()

func _respawn_spell() -> void:
	current_spell = packed_spell.instantiate()
	spell_handle.add_child(current_spell)

func _attack() -> void:
	if attack_cooldown.is_stopped():
		animationPlayer.play("SwordSwing")
		attack_cooldown.start()

func _deal_damage() -> void:
	for enemy in target:
		if enemy and enemy.is_inside_tree():
			enemy.take_damage(Global.damage)

func _inspect() -> void:
	if inspect_cooldown.is_stopped():
		animationPlayer.play("SwordInspect")
		inspect_cooldown.start()

func _shoot_spell() -> void:
	current_spell.reparent(get_tree().current_scene)
	current_spell.shoot(-global_transform.basis.z)
	spell_cooldown.start()

func update_HUD() -> void:
	healthBar.value = health
	staminaBar.value = stamina
	goldCounter.text = str(Global.gold)

func _ready() -> void:
	healthBar.max_value = maxHealth
	staminaBar.max_value = maxStamina
	camera.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	
	push_warning("in the editor the line of code below is for testing")
	set_spell(preload("res://scenes/spells/tempest_burst.tscn"))

#Input and camera handling
func _unhandled_input(event) -> void:
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func _switch_view() -> void:
	if camera == first_person_camera:
		first_person_camera.current = false
		third_person_camera.current = true
		camera = third_person_camera
	else:
		third_person_camera.current = false
		first_person_camera.current = true
		camera = first_person_camera

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		_attack()
	
	if event.is_action_pressed("inspect"):
		_inspect()
	
	if event.is_action_pressed("escape"):
		get_tree().quit()
	
	if event.is_action_pressed("slide"):
		_start_slide()
	
	if event.is_action_released("slide") and sliding:
		_end_slide()
	
	if event.is_action_pressed("switch_view"):
		_switch_view()
	
	if event.is_action_pressed("spell") and spell_cooldown.is_stopped():
		_shoot_spell()

func _process(_delta: float) -> void:
	update_HUD()
	stamina += 0.1

func _physics_process(delta: float) -> void:
	var speed: float = velocity.length()
	var density: float = 0.0
	# TODO: replace with math
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
	
	$HUD/Speedlines.material.set_shader_parameter("line_density", density)
	
	floor_snap_length = 0.3
	
	var input_vec: Vector2 = Input.get_vector("left", "right", "up", "down")
	input_dir = (transform.basis * Vector3(input_vec.x, 0, input_vec.y)).normalized()
	
	var target_speed: float = Global.move_speed
	if Input.is_action_pressed("sprint"):
		stamina -= 0.2
		target_speed = Global.sprint_speed
	
	# Smooth acceleration + air control
	var control: float = 1.0 if is_on_floor() else air_control
	if input_dir != Vector3.ZERO:
		move_dir = move_dir.lerp(input_dir * target_speed, acceleration * control * delta)
	else:
		move_dir = move_dir.lerp(Vector3.ZERO, acceleration * delta)
	
	# Gravity + jump
	if not is_on_floor():
		velocity_y -= gravity * delta
	elif not sliding:
		if Input.is_action_just_pressed("jump"):
			velocity_y = Global.jump_force
	
	if sliding:
		move_dir = move_dir.lerp(Vector3.ZERO, slide_decay * delta)
		velocity_y = -3.0  # keeps player pushed into the ground
		if move_dir.length() < Global.move_speed:
			_end_slide()
	
	# Combine
	velocity = move_dir + Vector3.UP * velocity_y
	
	# Stick to ground during slide
	floor_snap_length = 0.3 if is_on_floor() else 0.0
	
	move_and_slide()
	
	# camera
	var target_tilt: float = -input_vec.x * camera_tilt
	camera.rotation_degrees.z = lerp(camera.rotation_degrees.z, target_tilt, 10 * delta)
	
	# FOV widen
	if camera is Camera3D:
		var target_fov = 90.0 if sliding else 75.0
		camera.fov = lerp(camera.fov, target_fov, 5 * delta)

func _start_slide() -> void:
	if not is_on_floor() or sliding or stamina < 10 or not slide_cooldown.is_stopped():
		return
	
	sliding = true
	slide_cooldown.start()
	stamina -= 10
	move_dir = move_dir.normalized() * slide_speed
	velocity_y = -3.0  # pushes player down to stay grounded

func _end_slide() -> void:
	sliding = false

func _on_attack_cooldown_timeout() -> void:
	pass

func _on_inspect_cooldown_timeout() -> void:
	pass 

func _on_attack_zone_body_entered(body: Node3D) -> void:
	if body is Enemy and body != self: # TODO: Player is not an Enemy so this extra check should be obsolete
		print("Enemy entered: ", body.name)
		target.append(body)

func _on_attack_zone_body_exited(body: Node3D) -> void:
	if body is Enemy:
		target.erase(body)
