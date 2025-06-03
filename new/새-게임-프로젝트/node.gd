extends Node

@onready var DROP = preload("res://water_drop.tscn")
@onready var tree = get_parent().get_node("Tree")


func _on_button_pressed() -> void:
	var instance = DROP.instantiate()
	instance.global_position = Vector2(tree.global_position.x, tree.global_position.y-100)
	add_child(instance)
	
