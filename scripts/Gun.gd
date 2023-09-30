class_name Gun extends Node3D

@export var sfx_gunshot: Array[AudioStream] = []
@export var damage: int = 5

@onready var anim: AnimationPlayer = $AnimationPlayer
@onready var sfx_shoot: AudioStreamPlayer3D = $SFXPlayer_Shoot
@onready var gun_barrel: RayCast3D = $GunBarrel

# bullets
@onready var bullet_scene: PackedScene = preload("res://scenes/Bullet.tscn")
var bullet_instance

func can_shoot() -> bool:
	return !anim.is_playing()

func shoot():
	anim.play("Shoot")

	bullet_instance = bullet_scene.instantiate()
	bullet_instance.position = gun_barrel.global_position
	bullet_instance.transform.basis = gun_barrel.global_transform.basis
	get_tree().root.add_child(bullet_instance)

	var gunshot_index = randi() % sfx_gunshot.size()
	sfx_shoot.stream = sfx_gunshot[gunshot_index]
	sfx_shoot.play()

func get_time() -> float:
	return Time.get_ticks_msec() / 1000.0
