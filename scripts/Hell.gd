extends Node3D

@export var hitler_delay = 2.5
@export var vn_hitler: PackedScene

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
		var vn = vn_hitler.instantiate()
		add_child(vn)
		GameManager.play_music("res://music/Hitler.ogg")
	else:
		var closest_enemy = _get_enemy_closest_to_player()
		closest_enemy.say_voiceline()

func _get_enemy_closest_to_player() -> Enemy:
	var closest_dist = 100000
	var closest_enemy = null
	for enemy in enemies:
		if !is_instance_valid(enemy) or !enemy.target:
			continue
		var target = enemy.target
		var distance = (target.global_position - enemy.global_position).length()
		if distance < closest_dist:
			closest_enemy = enemy
	return closest_enemy
