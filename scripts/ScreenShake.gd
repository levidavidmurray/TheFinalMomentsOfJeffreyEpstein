extends Node

@export var random_strength = 30.0
@export var shake_fade = 5.0

@onready var camera: Camera3D = get_parent()
@onready var y_offset = camera.position.y

var rng = RandomNumberGenerator.new()

var shake_strength = 0.0

func _process(delta):
	if shake_strength > 0:
		shake_strength = lerpf(shake_strength, 0, shake_fade * delta)

		var offset = random_offset()
		camera.position = Vector3(offset.x, y_offset, camera.position.z)

		if shake_strength < 0.1:
			camera.position = Vector3(0, y_offset, camera.position.z)

func apply_shake():
	shake_strength = random_strength

func random_offset() -> Vector2:
	return Vector2(
		rng.randf_range(-shake_strength, shake_strength),
		rng.randf_range(-shake_strength, shake_strength)
	)
