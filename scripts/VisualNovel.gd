extends CanvasLayer

@export var dialogue_resource: DialogueResource

func _ready():
	await get_tree().create_timer(2.0).timeout
	DialogueManager.show_example_dialogue_balloon(dialogue_resource, "start")
