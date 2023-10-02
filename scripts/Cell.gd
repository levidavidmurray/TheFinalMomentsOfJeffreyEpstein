extends Node3D

@export var vn_hillary: PackedScene
@onready var world_env: WorldEnvironment = $WorldEnvironment

func _on_noose_interacted():
	var player = GameManager.player
	player.interact_label.visible = false
	$CanvasLayer/Question.visible = true
	player.disable_input = true
	player.release_mouse()

func _on_letter_interacted():
	var vn = vn_hillary.instantiate()
	add_child(vn)

func go_to_hell():
	var player = GameManager.player
	$CanvasLayer/Question.visible = false
	player.disable_input = false
	player.capture_mouse()
	if world_env:
		world_env.queue_free()
		world_env = null
	$Cell/StaticBody3D/CollisionShape3D.disabled = true
	$DirectionalLight3D.visible = false
	GameManager.go_to_hell()
	pass


func _on_button_yes_button_up():
	go_to_hell()


func _on_button_no_button_up():
	go_to_hell()
