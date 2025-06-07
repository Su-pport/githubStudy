extends Camera2D

func _process(delta: float) -> void:
	# player_position노드가 player의 좌표를 따라다님
	var player_position = get_node("player_positoin").position # 위 노드의 부모 노드 기준 좌표를 가져오기
	position_smoothing_speed = 5 # 화면이 움직이는 속도는 기본 5
	
	if player_position.x > 640: # 화면 오른쪽 밖으로 플레이어가 나갔다면
		position_smoothing_speed = 10 # 화면이 더 많이 움직여야 해서 10
		global_position.x += 1280
	elif player_position.x < -640: # 왼쪽으로
		position_smoothing_speed = 10
		global_position.x -= 1280
	elif player_position.y > 320: # 위 
		global_position.y += 640
	elif player_position.y < -320: # 아래
		global_position.y -= 640 # 위위 아래 -exid 위아래 - 
