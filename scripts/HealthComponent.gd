class_name HealthComponent extends Node

signal death

@export var max_health = 10

var current_health: int

func _ready():
	current_health = max_health

func is_dead() -> bool:
	return current_health == 0

func take_damage(damage: int) -> void:
	if (current_health == 0):
		return
	current_health = clamp(current_health - damage, 0, max_health)
	if current_health == 0:
		death.emit()
		
