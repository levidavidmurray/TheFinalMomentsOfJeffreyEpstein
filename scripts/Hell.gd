extends Node3D

@export var hitler_delay = 2.5
@export var vn_hitler: PackedScene
@export var sfx_voicelines: Array[AudioStream]

@onready var sfx_voiceline: AudioStreamPlayer = $SFX_Voiceline

var enemies
var enemies_remaining = 0

var sfx_played_map = {}

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
		vn.dialogue_ended.connect(_on_dialogue_ended)
		GameManager.play_music("res://music/Hitler.ogg")
	else:
		_play_voiceline()

func _play_voiceline():
	var stream = sfx_voicelines[randi() % sfx_voicelines.size()]

	while sfx_played_map.has(stream):
		stream = sfx_voicelines[randi() % sfx_voicelines.size()]

	sfx_played_map[stream] = true
	sfx_voiceline.stream = stream
	sfx_voiceline.play()

func _on_dialogue_ended():
	GameManager.end_game()


# func _get_enemy_closest_to_player() -> Enemy:
# 	var closest_dist = 100000
# 	var closest_enemy = null
# 	for enemy in enemies:
# 		if !is_instance_valid(enemy) or !enemy.target:
# 			continue
# 		var target = enemy.target
# 		var distance = (target.global_position - enemy.global_position).length()
# 		if distance < closest_dist:
# 			closest_enemy = enemy
# 	return closest_enemy
