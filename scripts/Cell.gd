extends Node3D

@export var vn_hillary: PackedScene

@onready var world_env: WorldEnvironment = $WorldEnvironment

func _on_noose_interacted():
	go_to_hell()

func _on_letter_interacted():
	var vn = vn_hillary.instantiate()
	add_child(vn)

func go_to_hell():
	if world_env:
		world_env.queue_free()
		world_env = null
	$Cell/StaticBody3D/CollisionShape3D.disabled = true
	$DirectionalLight3D.visible = false
	GameManager.go_to_hell()
	pass
