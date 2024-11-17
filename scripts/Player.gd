extends CharacterBody3D

var speed
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const JUMP_VELOCITY = 4.8
const SENSITIVITY = 0.007
# Bob variables
const BOB_FREQ = 2.4
const BOB_AMP = 0.08
var t_bob = 0.0
var can_throw = false
const BASE_FOV = 75.0
var FOV_CHANGE = 1.5
var gravity = 9.8
var Snowball = preload("res://scenes/snowball.tscn")

# Snowball gathering variables
var is_gathering = false
var gathering_progress = 0.0
const GATHERING_TIME = 2.0
const LOOK_DOWN_THRESHOLD = -0.0000001 
const MIN_SNOWBALL_SCALE = 0.1
const MAX_SNOWBALL_SCALE = 0.3

@onready var head = $Head
@onready var camera = $Head/Camera3D
@onready var held_snowball = $Head/Camera3D/HeldSnowball
@onready var snowball_reload_timer = $SnowballReloadTimer
@onready var gathering_bar: ProgressBar = $CanvasLayer/ProgressBar

func _ready():
	gathering_bar.visible = false
	if !head or !camera:
		return
		
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
	if !snowball_reload_timer:
		snowball_reload_timer = Timer.new()
		add_child(snowball_reload_timer)
		snowball_reload_timer.name = "SnowballReloadTimer"
	snowball_reload_timer.wait_time = 3.0
	snowball_reload_timer.one_shot = true
	
	if held_snowball:
		held_snowball.visible = false  
		held_snowball.position = Vector3(0.5, -0.3, -0.7)
		held_snowball.scale = Vector3(MIN_SNOWBALL_SCALE, MIN_SNOWBALL_SCALE, MIN_SNOWBALL_SCALE)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(60))

func _physics_process(delta):
	handle_movement(delta)
	handle_snowball_gathering(delta)
	snowball_throw()
	head_bob(delta)
	handle_fov(delta)
	move_and_slide()

func handle_snowball_gathering(delta):
	var looking_down = camera.global_transform.basis.z.y > LOOK_DOWN_THRESHOLD
	
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var is_moving = input_dir != Vector2.ZERO

	if Input.is_action_pressed("throw") and looking_down and is_on_floor() and not can_throw and not is_moving:
		is_gathering = true
		gathering_progress = min(gathering_progress + delta / GATHERING_TIME, 1.0)
		
	
		if held_snowball:
			held_snowball.visible = true
			gathering_bar.visible = true
			var current_scale = lerp(MIN_SNOWBALL_SCALE, MAX_SNOWBALL_SCALE, gathering_progress)
			held_snowball.scale = Vector3(current_scale, current_scale, current_scale)
			gathering_bar.value = lerp(0.0, 1.0, gathering_progress)
	
			
		if gathering_progress >= 1.0:
			can_throw = true
			is_gathering = false
	else:
		if is_gathering:
			is_gathering = false
			gathering_progress = 0.0
			if held_snowball and not can_throw:
				held_snowball.visible = false
				gathering_bar.visible = false

func snowball_throw():
	if can_throw:
		gathering_bar.visible = false
		
	if Input.is_action_just_pressed("throw") and can_throw:
		if held_snowball:
			held_snowball.visible = false
			gathering_bar.visible = false
		can_throw = false
		gathering_progress = 0.0
		
		var snowball_instance = Snowball.instantiate()
		snowball_instance.position = $Head/Camera3D/Snowballpos.global_position
		get_tree().current_scene.add_child(snowball_instance)
		
		var throw_direction = -camera.global_transform.basis.z.normalized()
		var throw_force = 18
		var up_force = 3.5
		
		snowball_instance.apply_central_impulse(throw_direction * throw_force + Vector3(0, up_force, 0))


func handle_movement(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED
		FOV_CHANGE = 2.5
	else:
		FOV_CHANGE = 1.5
		speed = WALK_SPEED
		
	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (head.transform.basis * transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed
			velocity.z = direction.z * speed
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 7.0)
			velocity.z = lerp(velocity.z, direction.z * speed, delta * 7.0)
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0)
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0)

func head_bob(delta):
	t_bob += delta * velocity.length() * float(is_on_floor())
	camera.transform.origin = _headbob(t_bob)

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos

func handle_fov(delta):
	var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2)
	var target_fov = BASE_FOV + FOV_CHANGE * velocity_clamped
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0)
