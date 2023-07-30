extends CharacterBody2D

const SPEED = 100.0

@onready var timer = $Timer
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var rng = RandomNumberGenerator.new()

var direction = 0
func _ready():
	change_direction()
	timer.start()

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
	
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
	direction = rng.randi_range(-1, 1)
	if direction:
		timer.wait_time = rng.randf_range(3, 5)
	else:
		timer.wait_time = rng.randf_range(0, 1.0)

func _on_timer_timeout():
	change_direction()
	timer.start()

func get_collision_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size
