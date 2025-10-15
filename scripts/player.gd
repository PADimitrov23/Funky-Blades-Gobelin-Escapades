extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 3
var sensitivity = 0.0005
var onCooldown = false
@onready var camera = $FirstPerson
@onready var animationPlayer = $SwordAnimations
@onready var attackCooldown = $AttackCooldown
@onready var inspectCooldown = $InspectCooldown
@onready var healthBar = $HUD/HealthBar
@onready var goldCounter = $HUD/GoldCounter

var gold = 0;
var health = 100;
var maxHealth = 100;
var damage = 10;
var target = [];

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * sensitivity)
		camera.rotate_x(-event.relative.y * sensitivity)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-60), deg_to_rad(70))

func _ready():
	healthBar.max_value = 100;
	$FirstPerson.current = true
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func player():
	pass

func attack():
	if Input.is_action_just_pressed("attack") and attackCooldown.is_stopped():
		animationPlayer.play("SwordSwing")
		attackCooldown.start()

func deal_damage():
	for enemies in target:
		if enemies and enemies.is_inside_tree():
			enemies.health -= damage

func inspect():
	if Input.is_action_just_pressed("inspect") and inspectCooldown.is_stopped():
		animationPlayer.play("SwordInspect")
		inspectCooldown.start()

func update_HUD():
	healthBar.value = health
	goldCounter.text = str(gold);

func _process(delta):
	attack()
	inspect()
	_switch_view()
	update_HUD()
	if Input.is_action_just_pressed("escape"): 
		get_tree().quit()

func _switch_view():
	if Input.is_action_just_pressed("switch_view"):
		if camera == $FirstPerson:
			camera = $Head
			$Head/ThirdPerson.current = true
		else:
			camera = $FirstPerson
			$FirstPerson.current = true

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("left", "right", "up", "down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

func _on_attack_cooldown_timeout() -> void:
	pass

func _on_inspect_cooldown_timeout() -> void:
	pass 


func _on_attack_zone_body_entered(body: Node3D) -> void:
	if body.has_method("enemy") and body != self:
		print("Enemy entered: ", body.name)
		target.append(body)


func _on_attack_zone_body_exited(body: Node3D) -> void:
	if body.has_method("enemy"):
		target.erase(body)
