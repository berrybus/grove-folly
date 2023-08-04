class_name Player
extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -1300.0
const LADDER_SPEED = 400
const FRICTION = 3600
const AIR_FRICTION = 500
const ATTACK_FRICTION = 1500
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var num_jumps = 0
const MAX_JUMPS = 1
const LADDER_MASK = 1 << 3
const ONE_WAY_MASK = 1 << 2
var h_flip_offset = 0
var one_way_map: TileMap
var ladder_map: TileMap
var ladder_map_below: TileMap
var ladder_rid_below: RID
# most recently interacted with laddder coordinate
var last_ladder_coord: Vector2i
var can_enter_ladder = true
var touching_objects: Array[InteractObject] = []

@onready var body_animation: AnimatedSprite2D = $BodyAnimation
@onready var sword_smear: AnimatedSprite2D = $SwordSmear
@onready var state_machine = $StateMachine
@onready var collision_shape_2d = $CollisionShape2D
@onready var ladder_timer: Timer = $LadderDetector/LadderTimer
@onready var sword_collision: CollisionShape2D = $Sword/SwordCollision
@onready var sword = $Sword
@onready var color_rect = $Sword/ColorRect
@onready var knockback_timer = $KnockbackTimer
@onready var invuln_timer = $InvulnTimer
@onready var animation_player = $AnimationPlayer
@onready var hitbox = $Hitbox
var sword_particles = preload("res://weapon_particles.tscn")

# Saved from hitbox
var other_area: Area2D
var other_shape_index: int
var hitbox_shape_index: int

func _ready():
	ladder_timer.stop()
	sword_collision.disabled = true
	
func _physics_process(_delta):
	# color_rect.visible = !sword_collision.disabled
	check_enemy_collision()
	if state_machine.state is PlayerAttack:
		return
	
	apply_flip()
	var space_state = get_world_2d().direct_space_state
	var xpos = collision_shape_2d.global_position.x
	# half of tile size + 1
	var ypos = collision_shape_2d.global_position.y + get_collision_size().y / 2 + 36
	var query = PhysicsRayQueryParameters2D.create(collision_shape_2d.global_position, Vector2(xpos, ypos), ONE_WAY_MASK)
	var result = space_state.intersect_ray(query)
	if result and result["collider"] is TileMap:
		one_way_map = result["collider"]
	else:
		one_way_map = null
	var ground_ypos = collision_shape_2d.global_position.y + get_collision_size().y / 2
	query = PhysicsRayQueryParameters2D.create(Vector2(xpos, ground_ypos), Vector2(xpos, ground_ypos + 1), LADDER_MASK)
	result = space_state.intersect_ray(query)
	if result and result["collider"] is TileMap and result["rid"] is RID:
		ladder_map_below = result["collider"]
		ladder_rid_below = result["rid"]
	else:
		ladder_map_below = null
	
	if InputScheme.is_action_just_pressed("interact") and len(touching_objects) > 0:
		touching_objects.front().show_dialogue()
		
		
func apply_flip():
	if state_machine.state is PlayerClimb:
		return
	var direction = InputScheme.get_axis("left", "right")
	if direction > 0:
		body_animation.flip_h = true
		body_animation.offset.x = h_flip_offset
	elif direction < 0:
		body_animation.flip_h = false
		body_animation.offset.x = 0
		
func get_collision_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size

func get_collision_offset() -> Vector2:
	return collision_shape_2d.position
	
func can_drop_down() -> bool:
	return one_way_map != null

func _on_object_detector_area_entered(area):
	if area is InteractObject:
		touching_objects.append(area)

func _on_object_detector_area_exited(area):
	if area is InteractObject:
		touching_objects.erase(area)

func facing_right() -> bool:
	return body_animation.flip_h

## Attacking/Sword ##

func _on_body_animation_animation_finished():
	if (body_animation.animation == "cast" or body_animation.animation == "attack") \
		and state_machine.state is PlayerAttack:
		state_machine.state.attack_anim_finished()

func _on_sword_area_shape_entered(_area_rid, area, area_shape_index, local_shape_index):
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	var other_shape = area.shape_owner_get_shape(other_shape_owner, area_shape_index)
	var shape_owner = sword.shape_find_owner(local_shape_index)
	var shape_node = sword.shape_owner_get_owner(shape_owner)
	var shape = sword.shape_owner_get_shape(shape_owner, local_shape_index)
	
	var points = shape.collide_and_get_contacts(
		shape_node.get_global_transform(),
		other_shape,
		other_shape_node.get_global_transform()
	)
	
	if points.size() < 2:
		print("no size")
		return
		
	var normal = (points[1] - points[0]).normalized()
	
	var particle = sword_particles.instantiate()
	add_child(particle)
	particle.emitting = true
	if normal.x > 0:
		particle.direction = Vector2(1, -1)
	else:
		particle.direction = Vector2(-1, -1)
	particle.global_position = points[0] + Vector2(0, -24)

## Getting hit/Knockback ##

func _on_invuln_timer_timeout():
	animation_player.stop()
	modulate = Color.WHITE

func _on_knockback_timer_timeout():
	if state_machine.state is PlayerHurt:
		state_machine.state.stop_knockback()

func check_enemy_collision():
	if invuln_timer.time_left > 0:
		return
		
	if not other_area:
		return
		
	var other_shape_owner = other_area.shape_find_owner(other_shape_index)
	var other_shape_node = other_area.shape_owner_get_owner(other_shape_owner)
	var other_shape = other_area.shape_owner_get_shape(other_shape_owner, other_shape_index)
	var shape_owner = hitbox.shape_find_owner(hitbox_shape_index)
	var shape_node = hitbox.shape_owner_get_owner(shape_owner)
	var shape = hitbox.shape_owner_get_shape(shape_owner, hitbox_shape_index)

	var points = shape.collide_and_get_contacts(
		shape_node.get_global_transform(),
		other_shape,
		other_shape_node.get_global_transform()
	)
	
	if points.size() < 2:
		return
	
	var normal = (points[1] - points[0]).normalized()
	if normal.x > 0:
		state_machine.transition_to("Hurt", { "knockback_dir": 1 })
	else:
		state_machine.transition_to("Hurt", { "knockback_dir": -1 })
	
func _on_hitbox_area_shape_entered(_area_rid, area, area_shape_index, local_shape_index):
	other_area = area
	other_shape_index = area_shape_index
	hitbox_shape_index = local_shape_index

func _on_hitbox_area_shape_exited(area_rid, area, area_shape_index, local_shape_index):
	if area == other_area:
		other_area = null
		other_shape_index = 0
		hitbox_shape_index = 0
		
## Ladders ##

func can_climb() -> bool:
	return ladder_map != null and can_enter_ladder
	
func can_climb_down() -> bool:
	return ladder_map_below != null and can_enter_ladder

# WARNING: this function assumes that we don't use body_shape_index or local_shape_index
func will_climb_down():
	if not ladder_map_below or not ladder_rid_below:
		return
	_on_ladder_detector_body_entered(ladder_map_below)
	_on_ladder_detector_body_shape_entered(ladder_rid_below, ladder_map_below, 0, 0)
	# this assumes that the ladder detector area has the same bottom as the player collision
	position.y += 1
	
func _on_ladder_detector_body_entered(body):
	ladder_map = body

func _on_ladder_detector_body_exited(_body):
	ladder_map = null
	if state_machine.state is PlayerClimb:
		state_machine.state.exit_ladder()

func _on_ladder_detector_body_shape_entered(body_rid, body, _body_shape_index, _local_shape_index):
	last_ladder_coord = body.get_coords_for_body_rid(body_rid)

func _on_ladder_detector_body_shape_exited(body_rid, body, _body_shape_index, _local_shape_index):
	last_ladder_coord = body.get_coords_for_body_rid(body_rid)

func _on_ladder_timer_timeout():
	can_enter_ladder = true
