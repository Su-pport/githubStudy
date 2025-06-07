extends CharacterBody2D

# === 이동 및 상태 ===
var speed = 150
var player_chase = false
var player = null

# === 체력 및 공격 ===
var max_hp = 3
var current_hp = max_hp
var damage = 1

# === 상태 플래그 ===
var can_attack = false
var is_attacking: bool = false
var is_hurt: bool = false
var is_dead: bool = false
var has_died: bool = false

# === 순찰 관련 ===
var patrol_state = null
var patrol_direction = Vector2.LEFT
var patrol_timer = 0.0
var patrol_interval = 2.0

# === 노드 참조 ===
@onready var hurtbox_pivot = $pivots/hurtbox_pivot
@onready var attack_area_pivot = $pivots/attack_area_pivot
@onready var hitbox_pivot = $pivots/hitbox_pivot
@onready var hitbox = $pivots/hitbox_pivot/hitbox
@onready var hitbox_switch = $pivots/hitbox_pivot/hitbox/CollisionShape2D
@onready var enemy_collision = $enemy_collision
@onready var sprite = $AnimatedSprite2D
@onready var world_collision = $world_collision

# === 상태 enum ===
enum {
	move,
	attack,
	hurt,
	death,
	patrol_move,
	patrol_idle,
}
var state = patrol_idle

# === 시작 ===
func _ready():
	hitbox_switch.disabled = true
	if not hitbox.is_connected("area_entered", Callable(self, "_on_area_entered")):
		hitbox.connect("area_entered", Callable(self, "_on_area_entered"))
	state = patrol_idle
	patrol_state = patrol_idle
	patrol_interval = randf_range(1.0, 3.0)

# === 메인 루프 ===
func _physics_process(delta: float) -> void:
	if is_dead:
		return  # 죽었으면 아무것도 안 함
	
	match state:
		move:
			move_state()
		attack:
			if not is_attacking and can_attack:
				is_attacking = true
				attack_state()
		hurt:
			play_hurt_animation()
		death:
			death_state()
		patrol_move, patrol_idle:
			handle_patrol(delta)

# === 플레이어 추적 ===
func move_state(): 
	if player_chase:
		var direction = (player.position - position).normalized()
		velocity = direction * speed
		sprite.play("move")
		move_and_slide()
		
		face_player()
	else:
		velocity = Vector2.ZERO
		sprite.play("idle")

func face_player():
	var facing_left = (player.position.x - position.x) < 0
	sprite.flip_h = facing_left
	var rotation = 180 if facing_left else 0
	attack_area_pivot.rotation_degrees = rotation
	hurtbox_pivot.rotation_degrees = rotation
	hitbox_pivot.rotation_degrees = rotation
	enemy_collision_position(not facing_left)

# === 순찰 AI ===
func handle_patrol(delta: float):
	patrol_timer += delta

	if patrol_state == patrol_move:
		# 벽에 부딪혔으면 방향 반전
		if is_on_wall():
			patrol_direction = -patrol_direction
			patrol_flip()

		velocity = patrol_direction * speed
		move_and_slide()
		sprite.play("move")

		if patrol_timer >= patrol_interval:
			patrol_timer = 0
			patrol_interval = randf_range(1.5, 3.5)
			state = patrol_idle
			patrol_state = patrol_idle

	elif patrol_state == patrol_idle:
		velocity = Vector2.ZERO
		sprite.play("idle")

		if patrol_timer >= patrol_interval:
			patrol_timer = 0
			patrol_interval = randf_range(1.5, 3.5)
			state = patrol_move
			patrol_state = patrol_move
			patrol_direction = Vector2.LEFT if randf() < 0.5 else Vector2.RIGHT
			patrol_flip()

func patrol_flip():
	if patrol_direction.x < 0:
		sprite.flip_h = true
		enemy_collision_position(false)
		world_collsion_position(false)
		hurtbox_pivot.rotation_degrees = 180
		hitbox_pivot.rotation_degrees = 180
		attack_area_pivot.rotation_degrees = 180
		
		
	else:
		sprite.flip_h = false
		enemy_collision_position(true)
		world_collsion_position(true)
		hurtbox_pivot.rotation_degrees = 0
		hitbox_pivot.rotation_degrees = 0
		attack_area_pivot.rotation_degrees = 0


# === 공격 ===
func attack_state():
	if is_dead:
		return
	sprite.play("attack")
	await get_tree().create_timer(0.4).timeout
	hitbox_switch.disabled = false
	await sprite.animation_finished
	hitbox_switch.disabled = true
	
	is_attacking = false
	
	state = attack if can_attack else move

func _on_area_entered(area: Area2D) -> void:
	if area.name == "hurtbox":
		var enemy = area.get_parent()
		if enemy.has_method("take_damage"):
			enemy.take_damage(damage)

# === 감지/공격 범위 ===
func _on_attack_area_area_entered(_area: Area2D) -> void:
	can_attack = true
	state = attack

func _on_attack_area_area_exited(_area: Area2D) -> void:
	can_attack = false

func _on_detection_area_body_entered(body: Node2D) -> void:
	player = body
	player_chase = true
	state = move

func _on_detection_area_body_exited(_body: Node2D) -> void:
	player = null
	player_chase = false
	state = patrol_idle
	patrol_state = patrol_idle
	patrol_timer = 0.0

# === 데미지 처리 ===
func take_damage(amount: int):
	if is_hurt or is_dead:
		return

	current_hp -= amount

	if current_hp <= 0:
		state = death
	else:
		state = hurt

func play_hurt_animation():
	hitbox_switch.disabled = true
	is_hurt = true
	if state != attack:
		sprite.play("take_damage")
		await sprite.animation_finished
	is_hurt = false
	state = attack if can_attack else move

func death_state():
	if has_died:
		return  # 이미 죽음 처리 중이면 무시

	has_died = true
	is_dead = true
	hitbox_switch.disabled = true
	velocity = Vector2.ZERO
	sprite.play("death")

	await sprite.animation_finished

	queue_free()


func die():
	is_dead = true
	sprite.play("death")
	await sprite.animation_finished
	queue_free()

# === 충돌 위치 회전 ===
func enemy_collision_position(is_facing_right: bool) -> void:
	if is_facing_right:
		enemy_collision.position.x = -4
	else:
		enemy_collision.position.x = 4

func world_collsion_position(is_facing_right: bool) -> void:
	if is_facing_right:
		world_collision.position.x = -2.5
	else:
		world_collision.position.x - 2.5
