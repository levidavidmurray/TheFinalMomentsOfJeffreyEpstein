class_name Interactable extends Node

signal interacted

func interact():
    interacted.emit()
