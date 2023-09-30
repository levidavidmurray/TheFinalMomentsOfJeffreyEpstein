class_name Enemy extends CharacterBody3D

## how long player has to stay in attack box before taking damage
@export var attack_box_delay = 0.25
@export var attack_damage = 3
@export var attack_interval = 1.5
@export var speed = 5.0
@export var stopping_distance = 1.0
@export var sfx_aggro: AudioStream
@export var sfx_attacks: Array[AudioStream]
@export var sfx_attacks_2: Array[AudioStream]
@export var sfx_death: AudioStream

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var sfx_2: AudioStreamPlayer3D = $SFX2
@onready var health_component: HealthComponent = $HealthComponent
@onready var start_pos = global_position
@onready var mesh = $MeshInstance3D
@onready var col = $CollisionShape3D
@onready var death_particles: GPUParticles3D = $DeathParticles

var target: Node3D = null
var last_attack_time = 0.0
var attack_box_enter_time = 0.0
var target_in_attack_box = false

func _physics_process(delta):
	if is_dead():
		return
	
	if target:
		handle_aggro()
	else:
		handle_patrol()

func handle_aggro():
	# move towards target
	var dir = target.global_position - global_position
	if can_attack():
		print("target in attack box: ", target_in_attack_box)
		velocity = Vector3.ZERO
		attack()
	else:
		velocity = dir.normalized() * speed
		move_and_slide()

func handle_patrol():
	var distance = (start_pos - global_position).length()
	if distance > 0.1:
		var dir = (start_pos - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		global_position = start_pos

func can_attack():
	if is_dead(): return false
	if not target: return false
	if not target_in_attack_box: return false
	if get_time() - attack_box_enter_time < attack_box_delay: return false
	return get_time() - last_attack_time > attack_interval

func attack():
	if not can_attack(): return
	last_attack_time = get_time()
	sfx.stream = sfx_attacks[randi() % sfx_attacks.size()]
	sfx.play()
	sfx_2.stream = sfx_attacks_2[randi() % sfx_attacks_2.size()]
	sfx_2.play()
	target.take_damage(attack_damage)
	# animator.play("Attack")
	# await get_tree().create_timer(attack_box_delay).timeout

func take_damage(damage):
	health_component.take_damage(damage)

func is_dead() -> bool:
	return health_component.is_dead()

func _on_health_component_death():
	sfx.stream = sfx_death
	sfx.play()
	mesh.visible = false
	col.disabled = true
	sfx.finished.connect(func(): queue_free())
	death_particles.emitting = true
	get_tree().root.add_child(death_particles)
	# animator.play("Death")

func _on_attack_box_body_entered(body:Node3D):
	if is_dead(): return
	if body == target:
		attack_box_enter_time = get_time()
		target_in_attack_box = true

func _on_attack_box_body_exited(body:Node3D):
	if body == target:
		target_in_attack_box = false

func _on_aggro_box_body_entered(body:Node3D):
	if is_dead(): return
	if body is Player:
		sfx.stream = sfx_aggro
		sfx.play()
		target = body
		target.death.connect(_on_target_death)

func _on_aggro_box_body_exited(body:Node3D):
	if body == target:
		target.death.disconnect(_on_target_death)
		target = null

func _on_target_death():
	target.death.disconnect(_on_target_death)
	target = null

func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0
