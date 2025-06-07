extends Node2D

# 1280 640

#12시부터 시계방향으로 문과 벽이 0, 1, 2, 3
#문은 항상 그자리에 있고 벽이 그 위를 덮어 씌워서 길이 없는것처럼 보임
@onready var closed_door
@onready var opened_door
@onready var enemy_gen # 같은 이름의 노드를 담기 위한 변수
@onready var visit = false # 방문 했던 곳인지 확할 bool
@onready var clear = false # 깬 곳인지 확인 
func _ready() -> void:
	closed_door = $dungeon_room/base_door # 진행중 쓸 변수 미리 담기
	opened_door = $dungeon_room/base_open
	enemy_gen = get_node("enemy_gen") #적을 잡았다면 이 노드를 없애서 다시 안생기게

func _physics_process(_delta: float) -> void:
	var mobs_num
	if(get_node("enemy_gen")!=null):
		mobs_num = get_node("enemy_gen").get_child_count()
	if enemy_gen == null : #한번 queue_free()를 진행했다면 다시 진행하지 않게 하는 조건문
		pass
	# enemy_gen의 하위 노드로는 적만 넣어서 그 수를 가져 올 노드
	elif mobs_num > 0 :
		closed_door.enabled = true # 문이 닫힘
		opened_door.visible = false # 문이 열리는 효과 없애기
			
	else: #하위 노드 수가 0이다 -> 적이 없다
		closed_door.enabled = false  # 열려버렷~♡
		opened_door.visible = true # 문이 열리는 효과
		if(visit): #방문 전에 몬스터 없다고 사라지는 것을 방지 
			enemy_gen.queue_free() #방문했고 몬스터 다잡으면 삭제 


func _on_enemy_gen_visit() -> void:
	visit = true
	pass # Replace with function body.
