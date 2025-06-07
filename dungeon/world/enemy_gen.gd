extends Node

signal visit # 방문한 방인지 확인하기 위한 신호

func start():
	var mob = preload("res://enemies/big_demon.tscn")
	var instance = mob.instantiate()
	instance.position.x = randi()%960 + 160
	instance.position.y = randi()%320 + 160
	add_child(instance)
	

func _on_area_2d_body_entered(body: Node2D) -> void:
	visit.emit() # 방문했다고 알림
	start()
