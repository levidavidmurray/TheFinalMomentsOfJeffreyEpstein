extends CanvasLayer

@export var dialogue_resource: DialogueResource
@export var background: Texture2D
@export var intro_delay = 2.0
@export var exit_delay = 1.0

func _ready():
	GameManager.visual_novel_mode()
	($Background as TextureRect).texture = background
	await get_tree().create_timer(intro_delay).timeout
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)

func _on_dialogue_ended(_resource):
	DialogueManager.dialogue_ended.disconnect(_on_dialogue_ended)
	await get_tree().create_timer(exit_delay).timeout
	GameManager.fps_mode()
	queue_free()
