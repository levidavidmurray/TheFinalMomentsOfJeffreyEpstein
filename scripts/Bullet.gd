extends Node3D

const SPEED = 50.0

@onready var mesh = $MeshInstance3D
@onready var ray = $RayCast3D
@onready var particles = $GPUParticles3D

var hit

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if ray.is_colliding():
		if ray.get_collider() != hit:
			hit = ray.get_collider()
			print("Hit:", ray.get_collider())
		mesh.visible = false
		particles.emitting = true
		await get_tree().create_timer(1.0).timeout
		queue_free()
	else:
		position += transform.basis * Vector3(0, 0, -SPEED) * delta

func _on_timer_timeout():
	queue_free()
