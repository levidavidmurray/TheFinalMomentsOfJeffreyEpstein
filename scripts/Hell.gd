extends Node3D

@export var hitler_delay = 2.5

var enemies
var enemies_remaining = 0

func _ready():
	enemies = get_tree().get_nodes_in_group("Enemy")
	enemies_remaining = enemies.size()

	# Connect to the signal
	for enemy in enemies:
		enemy.death.connect(_on_enemy_death)

func _on_enemy_death():
	enemies_remaining -= 1
	if enemies_remaining == 0:
		await get_tree().create_timer(hitler_delay).timeout
		GameManager.activate_hitler()