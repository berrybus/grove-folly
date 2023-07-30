extends CharacterBody2D

const SPEED = 100.0
const KNOCKBACK_SPEED = 200
const STUN_FRICTION = 800

enum State {
	KNOCKBACK,
	MOVE,
	STUN
}

@onready var change_direction_timer = $ChangeDirectionTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hitbox = $Hitbox
@onready var knockback_timer = $KnockbackTimer
@onready var stun_timer = $StunTimer


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
var cur_state = State.MOVE

var direction = 0
func _ready():
	change_direction()
	change_direction_timer.start()

func stun_process(delta):
	velocity.x = move_toward(velocity.x, 0, STUN_FRICTION * delta)
	
func knockback_process(delta):
	velocity.x = direction * KNOCKBACK_SPEED

func move_process(delta):
	check_empty_space()
	
	velocity.x = direction * SPEED
	
	if is_on_wall():
		direction *= -1
		position.x += direction * 10
		
	if direction > 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("walk")
	elif direction < 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.pause()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if cur_state == State.MOVE:
		move_process(delta)
	elif cur_state == State.KNOCKBACK:
		knockback_process(delta)
	elif cur_state == State.STUN:
		print("is stunned")
		stun_process(delta)
	
	move_and_slide()
	
func check_empty_space():
	var space_state = get_world_2d().direct_space_state
	var xpos_right = collision_shape_2d.global_position.x + get_collision_size().x / 2 + 1
	var ypos_start = collision_shape_2d.global_position.y
	var ypos = ypos_start + get_collision_size().y / 2 + 1
	var right_query = PhysicsRayQueryParameters2D.create(Vector2(xpos_right, ypos_start), Vector2(xpos_right, ypos))
	var right_result = space_state.intersect_ray(right_query)
	if not right_result and direction == 1:
		direction = -1
		
	var xpos_left = collision_shape_2d.global_position.x - get_collision_size().x / 2 - 1
	var left_query = PhysicsRayQueryParameters2D.create(Vector2(xpos_left, ypos_start), Vector2(xpos_left, ypos), collision_mask)
	var left_result = space_state.intersect_ray(left_query)
	if not left_result and direction == -1:
		direction = 1

func change_direction():
	if cur_state != State.MOVE:
		return
	direction = rng.randi_range(-1, 1)
	if direction:
		change_direction_timer.wait_time = rng.randf_range(3, 5)
	else:
		change_direction_timer.wait_time = rng.randf_range(0, 1.0)

func _on_timer_timeout():
	change_direction()
	change_direction_timer.start()

func get_collision_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size

func _on_hitbox_area_entered(area):
	if cur_state == State.KNOCKBACK:
		return
	var player = area.get_owner()
	if not (player is Player):
		print("not player")
		return
	if player.facing_right():
		print("attack from right")
		direction = 1
	else:
		print("attack from left")
		direction = -1
	animated_sprite_2d.pause()
	cur_state = State.KNOCKBACK
	velocity.y = -200
	knockback_timer.start()
	modulate = Color.INDIAN_RED

func _on_knockback_timer_timeout():
	cur_state = State.STUN
	stun_timer.start()
	modulate = Color.WHITE

func _on_stun_timer_timeout():
	if cur_state == State.STUN:
		cur_state = State.MOVE
