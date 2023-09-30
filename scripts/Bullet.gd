class_name Bullet extends Node3D

const SPEED = 50.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

var damage = 0
var did_hit = false

func _physics_process(delta):
	if did_hit: return

	if ray.is_colliding():
		did_hit = true
		var body = ray.get_collider()
		if body.has_method("take_damage"):
			body.take_damage(damage)
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta

func _on_timer_timeout():
	queue_free()
