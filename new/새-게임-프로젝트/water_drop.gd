extends Node2D

@onready var deadline = global_position.y + 100

func _process(delta: float) -> void:
	global_position.y += 300*delta
	if global_position.y == deadline :
		queue_free()
