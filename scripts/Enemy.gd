class_name Enemy extends CharacterBody3D

## how long player has to stay in attack box before taking damage
@export var attack_box_delay = 0.25
@export var attack_damage = 3
@export var speed = 5.0
@export var stopping_distance = 1.0
@export var sfx_aggro: AudioStream
@export var sfx_death: AudioStream

@onready var animator: AnimationPlayer = $AnimationPlayer
@onready var sfx: AudioStreamPlayer3D = $SFX
@onready var health_component: HealthComponent = $HealthComponent
@onready var start_pos = global_position

var target: Node3D = null

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
	if dir.length() > stopping_distance:
		velocity = dir.normalized() * speed
		move_and_slide()
	else:
		velocity = Vector3.ZERO
		# animator.play("Attack")
		# await get_tree().create_timer(attack_box_delay).timeout

func handle_patrol():
	var distance = (start_pos - global_position).length()
	if distance > 0.1:
		var dir = (start_pos - global_position).normalized()
		velocity = dir * speed
		move_and_slide()
	else:
		global_position = start_pos

func take_damage(damage):
	health_component.take_damage(damage)

func is_dead() -> bool:
	return health_component.is_dead()

func _on_health_component_death():
	sfx.stream = sfx_death
	sfx.play()
	animator.play("Death")

func _on_attack_box_body_entered(body:Node3D):
	if body is Player:
		body.take_damage(attack_damage)
		# await get_tree().create_timer(attack_box_delay).timeout

func _on_aggro_box_body_entered(body:Node3D):
	if body is Player:
		sfx.stream = sfx_aggro
		sfx.play()
		target = body

func _on_aggro_box_body_exited(body:Node3D):
	if body is Player:
		target = null
