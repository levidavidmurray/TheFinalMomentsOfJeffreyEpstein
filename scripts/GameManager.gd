class_name GameManager extends Node

@export var enemy: PackedScene

func _ready():
    var enemy_instance = enemy.instance()
    add_child(enemy_instance)