class_name Interactable extends StaticBody3D

signal interacted

@export var text = "interact"

func interact():
	interacted.emit()
