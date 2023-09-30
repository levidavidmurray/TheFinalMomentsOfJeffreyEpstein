class_name Player extends CharacterBody3D

@export_category("Player")
@export_range(1, 35, 1) var speed: float = 10 # m/s
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1
@export var take_damage_cd := 1.5
@export var footstep_sfx_interval := 0.5
@export var sfx_footsteps: Array[AudioStream] = []

var jumping: bool = false
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

var last_step_time := 0.0
var footstep_index = 0

@onready var camera: PlayerCamera = $Camera
@onready var health_component: HealthComponent = $HealthComponent
@onready var gun: Gun = $Camera/Gun
@onready var sfx_footstep: AudioStreamPlayer3D = $SFX_Footstep


func _ready() -> void:
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("exit"): get_tree().quit()
	if Input.is_action_just_pressed("shoot"): handle_shoot()

func _physics_process(delta: float) -> void:
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	velocity = _walk(delta) + _gravity(delta) + _jump(delta)

	move_and_slide()

	if sfx_footstep:
		_handle_footstep()

func take_damage(damage: float) -> void:
	health_component.take_damage(damage)

func handle_shoot() -> void:
	if not gun.can_shoot():
		return

	gun.shoot()
	var enemy = camera.get_shoot_enemy()
	if enemy:
		enemy.take_damage(gun.damage)

func _on_health_component_death():
	print("player died")
	pass # Replace with function body.

# Input & Physics

func capture_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true

func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false

func _rotate_camera(sens_mod: float = 1.0) -> void:
	camera.rotation.y -= look_dir.x * camera_sens * sens_mod
	camera.rotation.x = clamp(camera.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)

func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	return
	var joypad_dir: Vector2 = Input.get_vector("look_left","look_right","look_up","look_down")
	if joypad_dir.length() > 0:
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO

func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_backwards")
	var _forward: Vector3 = camera.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), acceleration * delta)
	return walk_vel

func _gravity(delta: float) -> Vector3:
	# grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	if is_on_floor():
		grav_vel = Vector3.ZERO
	else:
		grav_vel = grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
		
	return grav_vel

func _jump(delta: float) -> Vector3:
	if jumping:
		if is_on_floor(): jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
		jumping = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func _handle_footstep():
	if velocity.length() < 0.1 or not is_on_floor():
		return
	if sfx_footstep.playing:
		return
	if get_time() - last_step_time < footstep_sfx_interval:
		return

	
	last_step_time = get_time()
	sfx_footstep.stream = sfx_footsteps[footstep_index]
	sfx_footstep.pitch_scale = randf_range(0.75, 1)
	sfx_footstep.play()
	footstep_index = (footstep_index + 1) % sfx_footsteps.size()

func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0
