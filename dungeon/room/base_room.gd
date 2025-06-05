extends Node2D

# 1280 640

#12시부터 시계방향으로 문과 벽이 0, 1, 2, 3
#문은 항상 그자리에 있고 벽이 그 위를 덮어 씌워서 길이 없는것처럼 보임
var doors = ["top_door", "right_door", "bottom_door", "left_door"]
var walls = ["top_wall", "right_wall", "bottom_wall", "left_wall"]

var tmp

func _ready() -> void:
	var add_room = preload("res://room/base_room.tscn") # 맵을 늘리기 위해 본인을 저장
	var stage = get_parent()
	
	#실험용으로 0, 1 개방
	var room_setting = $dungeon_room # 타일레이어를 묶은 노드를 변수로 가져옴
	var door_nums # 개방할 문의 개수를 랜덤으로 가져옴
	if(name=="base_room"): # 이 방이 메인 방이라면
		door_nums = randi()%3+1 # 최소 1개
	else:
		door_nums = randi()%4 # 그냥 랜덤
		 
	for i in door_nums: # 그 수만큼 반복
		var door_dir = randi()%4 # 문을 열 방향의 인덱스를 랜덤으로 가져옴
		tmp = room_setting.get_node(walls[door_dir]) # 버릴 변수에 없애버릴 벽 노드를 가져옴
		tmp.queue_free() # 사라져버렷!@
		
		var gen_map = true
		var instance = add_room.instantiate()
		if(door_dir == 0):
			instance.position.x = global_position.x
			instance.position.y = global_position.y - 1280
		elif(door_dir == 1):
			instance.position.x = global_position.x + 640
			instance.position.y = global_position.y
		elif(door_dir == 2):
			instance.position.x = global_position.x
			instance.position.y = global_position.y + 1280
		elif(door_dir == 3):
			instance.position.x = global_position.x- 640
			instance.position.y = global_position.y 
		else :
			gen_map = false
			
		if(gen_map):
			stage.add_child(instance)
		else : 
			pass
		
	
	tmp = $dungeon_room/base_door # 진행중 쓸 변수 미리 담기d

func _physics_process(delta: float) -> void:
	if tmp == null : #한번 queue_free()를 진행했다면 다시 진행하지 않게 하는 조건문
		pass
	# enemy_gen의 하위 노드로는 적만 넣어서 그 수를 가져 올 노드
	elif $enemy_gen.get_child_count() == 0: #하위 노드 수가 0이다 -> 적이 없다
		tmp.queue_free()  # 사라져버렷~♡
		$dungeon_room/base_open.visible = true # 문이 열리는 효과
