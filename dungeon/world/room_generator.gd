extends Node2D

func _ready() -> void:
	var room = preload("res://room/new_base.tscn") #방 복사 준비
	
	var room_cnt = 1 # 방 개수
	var max_room = get_parent().max_room
	
	var is_room = [Vector2.ZERO, Vector2.ZERO] # 방들의 좌표를 저장 
	is_room.resize(max_room)
	
	while room_cnt < max_room: #최대 개수만큼 반복
		var new_room = room.instantiate()
		var room_dir = randi()%4 # 방향 랜덤으로 정하기
		var bool_add = true # 방을 추가 하지 않을 조건
		
		new_room.position = is_room[randi()%room_cnt]
		if(room_dir == 0) : 
			new_room.position.y -= 640
		elif(room_dir == 1):
			new_room.position.x += 1280 # 추가할 방의 좌표 설정
		elif(room_dir == 2):
			new_room.position.y +=640
		elif(room_dir == 3):
			new_room.position.x -= 1280 # 추가할 방의 좌표 설정 
		
		for i in is_room:
			if new_room.position == i:
				bool_add = false
		
		if(bool_add):
			is_room[room_cnt] = new_room.position
			add_child(new_room)
			room_cnt += 1
		else:
			new_room.queue_free()
	
