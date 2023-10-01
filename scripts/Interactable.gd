class_name Interactable extends Node

signal interacted

@export var text = "interact"

func interact():
	interacted.emit()
