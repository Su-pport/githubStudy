extends AnimatedSprite2D

func _process(delta: float) -> void:
	if global_scale > Vector2(14, 14) :
		set_frame_and_progress(1, 1)

func _on_button_pressed() -> void:
	global_scale += Vector2(0.1, 0.1)
	global_position = Vector2(global_position.x, global_position.y-0.8)
	
