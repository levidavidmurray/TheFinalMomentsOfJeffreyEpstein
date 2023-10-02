extends Node

var game_restart_delay = 3.5
var player: Player

func player_ready(_player: Player):
	print("GameManager::player_ready")
	player = _player
	player.death.connect(_on_player_death)

func visual_novel_mode():
	player.get_node("CanvasLayer").visible = false
	player.disable_input = true
	player.release_mouse()

func fps_mode():
	player.get_node("CanvasLayer").visible = true
	player.disable_input = false
	player.capture_mouse()
	
func go_to_hell():
	player.activate_hell_mode()
	music_player().stop()
	print("Go to hell")

func play_music(res_path):
	var music = music_player()
	music.stream = load(res_path)
	music.play()
	
func music_hell():
	var music = music_player()
	music.stream = load("res://music/Hell.ogg")
	music.play()

func end_game():
	get_node("/root/Main/EndGameLayer").visible = true
	player.get_node("CanvasLayer").visible = false
	player.disable_input = true
	player.release_mouse()
	

func _on_player_death():
	music_player().stop()
	player.death.disconnect(_on_player_death)
	await get_tree().create_timer(game_restart_delay).timeout
	get_tree().reload_current_scene()

func get_hell() -> Node3D:
	return get_node("../Main/Hell")

func music_player() -> AudioStreamPlayer:
	return get_node("../Main/MusicPlayer")
