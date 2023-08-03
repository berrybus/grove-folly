class_name GroundEnemy
extends CharacterBody2D

@export var SPEED = 100.0
@export var KNOCKBACK_SPEED = 200
@export var KNOCKBACK_JUMP = -200
const STUN_FRICTION = 800

@export var health: int

enum State {
	KNOCKBACK,
	MOVE,
	STUN,
	FOLLOW
}

@onready var change_direction_timer = $ChangeDirectionTimer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D
@onready var hitbox = $Hitbox
@onready var knockback_timer = $KnockbackTimer
@onready var stun_timer = $StunTimer
@onready var follow_timer = $FollowTimer

var damage_text = preload("res://damage_text.tscn") 
var death_particles = preload("res://death_particles.tscn") 

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()
var cur_state = State.MOVE
var player: Player = null

var direction = 0
func _ready():
	change_direction()
	change_direction_timer.start()

func stun_process(delta):
	velocity.x = move_toward(velocity.x, 0, STUN_FRICTION * delta)
	
func knockback_process(_delta):
	velocity.x = direction * KNOCKBACK_SPEED

func move_process(_delta):
	check_empty_space(1)
	
	if is_on_wall():
		direction *= -1
	
	velocity.x = direction * SPEED
	
	apply_animation()

# Assumes player exists
func follow_process(_delta):
	if not player:
		return
	# 24 is just a fuzzy approximation for "half of the player" so the enemy
	# has some wiggle room instead of spinning in place
	if abs(player.global_position.x - global_position.x) > 24:
		if player.global_position.x > global_position.x:
			direction = 1
		else:
			direction = -1
	else:
		direction = 0
	
	check_empty_space(0)
	
	velocity.x = direction * SPEED
	
	apply_animation()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if cur_state == State.MOVE:
		move_process(delta)
	elif cur_state == State.KNOCKBACK:
		knockback_process(delta)
	elif cur_state == State.STUN:
		stun_process(delta)
	elif cur_state == State.FOLLOW and player:
		follow_process(delta)
	
	move_and_slide()
	
func check_empty_space(dir_mult):
	var space_state = get_world_2d().direct_space_state
	var xpos_right = collision_shape_2d.global_position.x + get_collision_size().x / 2 + 1
	var ypos_start = collision_shape_2d.global_position.y
	var ypos = ypos_start + get_collision_size().y / 2 + 1
	var right_query = PhysicsRayQueryParameters2D.create(Vector2(xpos_right, ypos_start), Vector2(xpos_right, ypos))
	var right_result = space_state.intersect_ray(right_query)
	if not right_result and direction == 1:
		direction = -1 * dir_mult
		
	var xpos_left = collision_shape_2d.global_position.x - get_collision_size().x / 2 - 1
	var left_query = PhysicsRayQueryParameters2D.create(Vector2(xpos_left, ypos_start), Vector2(xpos_left, ypos), collision_mask)
	var left_result = space_state.intersect_ray(left_query)
	if not left_result and direction == -1:
		direction = 1 * dir_mult

func change_direction():
	if cur_state != State.MOVE:
		return
	direction = rng.randi_range(-1, 1)
	if direction:
		change_direction_timer.wait_time = rng.randf_range(3, 5)
	else:
		change_direction_timer.wait_time = rng.randf_range(0, 1.0)

func apply_animation():
	if direction > 0:
		animated_sprite_2d.flip_h = true
		animated_sprite_2d.play("walk")
	elif direction < 0:
		animated_sprite_2d.flip_h = false
		animated_sprite_2d.play("walk")
	else:
		animated_sprite_2d.pause()
		
func _on_timer_timeout():
	change_direction()
	change_direction_timer.start()

func get_collision_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size

func take_damage():
	var dmg_taken = rng.randi_range(1, 4)
	health -= dmg_taken
	# Enemy dead!
	if health <= 0:
		var particles = death_particles.instantiate()
		get_owner().add_child(particles)
		particles.global_position = global_position
		particles.emitting = true
		queue_free()
	var text = damage_text.instantiate()
	text.dmg = dmg_taken
	var world = get_owner()
	world.add_child(text)
	text.global_position = global_position + Vector2(0, -get_collision_size().y)
	
func _on_hitbox_area_entered(area):
	if cur_state == State.KNOCKBACK:
		return
	take_damage()
	player = area.get_owner()
	if not (player is Player):
		return
	if player.facing_right():
		direction = 1
	else:
		direction = -1
	animated_sprite_2d.pause()
	cur_state = State.KNOCKBACK
	velocity.y = KNOCKBACK_JUMP
	knockback_timer.start()
	modulate = Color(0.974, 0.5, 0.492)

func _on_knockback_timer_timeout():
	cur_state = State.STUN
	stun_timer.start()
	modulate = Color.WHITE

func _on_stun_timer_timeout():
	if cur_state == State.STUN:
		cur_state = State.FOLLOW
		follow_timer.start()

func _on_follow_timer_timeout():
	if cur_state == State.FOLLOW:
		cur_state = State.MOVE
