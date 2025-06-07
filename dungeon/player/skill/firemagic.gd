extends Node2D
 
var direction: Vector2 = Vector2.ZERO #방향을 저장하는 변수 (플레이어 방향 기준)
var damage = 1 #마법의 데미지

@onready var sprite: AnimatedSprite2D = $pivot/AnimatedSprite2D
@onready var hitbox: Area2D = $pivot/hitbox
@onready var shape = $pivot

func _ready():
	hitbox.connect("area_entered", Callable(self, "_on_area_entered")) #히트박스 충돌 감지 연결
	_update_animation()
	_start_lifetime_timer()

func _on_area_entered(area):
	if area.name == "hurtbox": #허트박스 이름이 "hurtbox"이면
		var enemy = area.get_parent().get_parent().get_parent() #부모노드를 가져와서
		if enemy.has_method("take_damage"): #부모노드에 take_damage가 있는지 확인
			enemy.take_damage(damage) #take_damage를 실행

func _update_animation(): #플레이어의 방향으로 마법을 pivot을 기준으로 회전시키는 함수
	if direction.x > 0: #오른쪽
		sprite.play("fire")	
		shape.rotation_degrees = 270
	elif direction.x < 0: #왼쪽
		sprite.play("fire")
		shape.rotation_degrees = 90
	elif direction.y > 0: #아래
		sprite.play("fire")
		shape.rotation_degrees = 0
	elif direction.y < 0: #위
		sprite.play("fire")
		shape.rotation_degrees = 180

func _start_lifetime_timer(): #마법 사용후 0.2초뒤 사라지는 함수
	await get_tree().create_timer(0.2).timeout 
	queue_free()
