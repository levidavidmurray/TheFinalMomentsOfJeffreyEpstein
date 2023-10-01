extends Node3D

@onready var world_env: WorldEnvironment = $WorldEnvironment

func _on_noose_interacted():
	go_to_hell()

func go_to_hell():
	if world_env:
		world_env.queue_free()
		world_env = null
	$Cell/StaticBody3D/CollisionShape3D.disabled = true
	$DirectionalLight3D.visible = false
	GameManager.go_to_hell()
	pass
