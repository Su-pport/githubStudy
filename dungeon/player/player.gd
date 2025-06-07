extends CharacterBody2D

@export var max_speed = 150
@export var acceleration = 800
@export var friction = 800
@onready var firemagic_scene = preload("res://player/skill/firemagic.tscn")
@onready var attack_duration := 0.2 #공격 애니메이션 0.2초

var max_hp = 1 #최대 채력
var current_hp = max_hp #현재 체력

var is_hurt: bool = false #데미지를 받은 여부
var is_dead: bool = false #죽으면 true
var has_died: bool = false

var facing_direction := Vector2.RIGHT

enum{
	move,
	attack,
	hurt,
	death
}

var state = move

func _physics_process(delta: float) -> void:
	match state:
		move:
			move_state(delta)
		attack:
			attack_state()
		hurt:
			pass
		death:
			if not has_died:
				has_died = true
				die()
				

func move_state(delta): #움직임 함수
	var input_vector = Vector2.ZERO
	input_vector.y = Input.get_action_strength("down") - Input.get_action_strength("up")
	input_vector.x = Input.get_action_strength("right") - Input.get_action_strength("left")
	input_vector = input_vector.normalized()
	$AnimatedSprite2D.play("idle")
	if input_vector.x<0:
		$AnimatedSprite2D.flip_h = true
	elif input_vector.x>0:
		$AnimatedSprite2D.flip_h = false
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * max_speed, acceleration * delta)
		facing_direction = input_vector
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()

	if Input.is_action_just_pressed("att"): #공격을 입력하면
		state = attack #상태가 attack이 됨

func attack_state(): #공격 함수
	var firemagic = firemagic_scene.instantiate() #firemage_scene에서 인스턴스 생성
	firemagic.position = position #시작 위치를 현재 캐릭터 위치로 설정
	firemagic.direction = facing_direction.normalized() #파이어볼의 방향을 캐릭터가 바라보는 방향
	get_parent().add_child(firemagic) #파이어볼을 현재 씬에 추가
	await get_tree().create_timer(attack_duration).timeout #attack_duration동안 캐릭터 정지
	velocity=Vector2.ZERO #공격이 끝나고 멈춰있도록 속도 0
	state = move #공격이 끝나면 다시 상태가 move로 바뀜

func take_damage(amount: int): #대미지 받는 코드 / 히트박스에서 허트박스를 감지했을때 히트박스 부모가 작동시키는 코드
	if is_hurt or is_dead: #현재 데미지를 받고 있거나 죽은 상태일때 넘기는 코드
		return
	
	current_hp -= amount #현재 체력에서 amount만큼 빼기
	print(current_hp)
	if current_hp <= 0: #체력이 0이되면 죽음
		is_dead = true
		state = death

func die():
	$AnimatedSprite2D.play("death")
	$world_collision.disabled = true
	$hurtbox/CollisionShape2D.disabled = true
