class_name PlayerCamera extends Camera3D

@onready var shoot_ray: RayCast3D = $ShootRay
@onready var interactable_ray: RayCast3D = $InteractableRay

var had_interactable_last_frame := false

func _physics_process(delta):
	# _detect_interactions()
	pass

func shake():
	$ScreenShake.apply_shake()

func get_shoot_enemy() -> Enemy:
	if shoot_ray.is_colliding():
		var body = shoot_ray.get_collider()
		if body is Enemy:
			return body

	return null

func get_shoot_target() -> Vector3:
	if shoot_ray.is_colliding():
		return shoot_ray.get_collision_point()
	else:
		return shoot_ray.get_global_transform().origin + shoot_ray.get_global_transform().basis.z * 1000
