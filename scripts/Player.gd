class_name Player extends CharacterBody3D

signal death

@export_category("Player")
@export_range(10, 400, 1) var acceleration: float = 100 # m/s^2
@export var speed_cell = 4
@export var speed_hell = 7

@export_range(0.1, 3.0, 0.1) var jump_height: float = 1 # m
@export_range(0.1, 3.0, 0.1, "or_greater") var camera_sens: float = 1
@export var take_damage_cd := 1.5
@export var footstep_sfx_interval := 0.5
@export var sfx_footsteps_cell: Array[AudioStream] = []
@export var sfx_footsteps_hell: Array[AudioStream] = []

@onready var camera: PlayerCamera = $Camera
@onready var health_component: HealthComponent = $HealthComponent
@onready var gun: Gun = $Camera/Gun
@onready var sfx_footstep: AudioStreamPlayer3D = $SFX_Footstep
@onready var sfx_footsteps: Array[AudioStream] = sfx_footsteps_cell
@onready var sfx_hell_impact: AudioStreamPlayer3D = $SFX_HellImpact
@onready var speed = speed_cell
@onready var interact_ray: RayCast3D = $Camera/InteractRay
@onready var interact_label: Label = $CanvasLayer/CenterContainer/InteractLabel

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
var is_hell_mode = false

var was_grounded_last_frame = false
var on_did_become_grounded: Callable
var disable_input = false

func _ready() -> void:
	GameManager.player_ready(self)
	capture_mouse()

func _unhandled_input(event: InputEvent) -> void:
	if Input.is_action_just_pressed("exit"): get_tree().quit()

	if is_dead() or disable_input: return

	if event is InputEventMouseMotion:
		look_dir = event.relative * 0.001
		if mouse_captured: _rotate_camera()
	if Input.is_action_just_pressed("jump"): jumping = true
	if Input.is_action_just_pressed("shoot"): handle_shoot()

func _physics_process(delta: float) -> void:
	if is_dead(): return

	velocity = _walk(delta) + _gravity(delta) + _jump(delta)

	move_and_slide()
	
	handle_interactable()

	if is_on_floor() and not was_grounded_last_frame:
		if on_did_become_grounded:
			on_did_become_grounded.call()

	if sfx_footstep:
		_handle_footstep()

	was_grounded_last_frame = is_on_floor()

func take_damage(damage: float) -> void:
	print("Player took damage: ", damage)
	camera.shake()
	health_component.take_damage(damage)

func is_dead() -> bool:
	return health_component.is_dead()

func handle_shoot() -> void:
	if not is_hell_mode: return
	if gun.can_shoot():
		gun.shoot()

func handle_interactable():
	
	if disable_input:
		return
	
	if interact_ray.is_colliding():
		var body = interact_ray.get_collider()
		var interactable = body.get_node("Interactable") as Interactable
		interact_label.visible = true
		interact_label.text = interactable.text
		if Input.is_action_just_pressed("interact"):
			interactable.interact()
	else:
		interact_label.visible = false		
	
func activate_hell_mode():
	is_hell_mode = true
	$Camera/DirectionalLight3D.visible = true
	sfx_footsteps = sfx_footsteps_hell
	$SFX_Fall.play()
	on_did_become_grounded = func():
		$SFX_Fall.stop()
		print("hell impact")
		GameManager.music_hell()
		sfx_hell_impact.play()
		speed = speed_hell
		gun.visible = true
		on_did_become_grounded = func(): pass

# Signal Callbacks

func _on_health_component_death():
	print("player died")
	$CanvasLayer/BlackRect.visible = true
	death.emit()

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

func _walk(delta: float) -> Vector3:
	if disable_input: return Vector3.ZERO
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

	
	footstep_index = (footstep_index + 1) % sfx_footsteps.size()
	last_step_time = get_time()
	sfx_footstep.stream = sfx_footsteps[footstep_index]
	sfx_footstep.pitch_scale = randf_range(0.75, 1)
	sfx_footstep.play()

func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0

func _on_button_restart_button_up():
	get_tree().reload_current_scene()

func _on_button_quit_button_up():
	get_tree().quit()
