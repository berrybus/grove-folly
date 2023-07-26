class_name Player
extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -1300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 4
var num_jumps = 0
const MAX_JUMPS = 2
const LADDER_MASK = 1 << 3
const ONE_WAY_MASK = 1 << 2
var h_flip_offset = 0
var one_way_map: TileMap
var ladder_map: TileMap
var ladder_map_below: TileMap
var last_ladder_coord: Vector2i

@onready var body_animation: AnimatedSprite2D = $BodyAnimation
@onready var sword_smear: AnimatedSprite2D = $SwordSmear
@onready var state_machine = $StateMachine
@onready var collision_shape_2d = $CollisionShape2D
	
func _physics_process(_delta):
	if state_machine.state is PlayerAttack:
		return
		
	apply_flip()
	var space_state = get_world_2d().direct_space_state
	var xpos = collision_shape_2d.global_position.x
	var ypos = collision_shape_2d.global_position.y + get_collision_size().y / 2 + 1
	var query = PhysicsRayQueryParameters2D.create(collision_shape_2d.global_position, Vector2(xpos, ypos), ONE_WAY_MASK)
	var result = space_state.intersect_ray(query)
	if result and result["collider"] is TileMap:
		one_way_map = result["collider"]
	else:
		one_way_map = null
	query = PhysicsRayQueryParameters2D.create(Vector2(xpos, ypos - 1), Vector2(xpos, ypos), LADDER_MASK)
	result = space_state.intersect_ray(query)
	if result and result["collider"] is TileMap:
		ladder_map_below = result["collider"]
	else:
		ladder_map_below = null
	
func apply_flip():
	if state_machine.state is PlayerClimb:
		return
	var direction = Input.get_axis("ui_left", "ui_right")
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
	
func can_climb() -> bool:
	return ladder_map != null
	
func can_climb_down() -> bool:
	return ladder_map_below != null

func _on_body_animation_animation_finished():
	if body_animation.animation == "attack" or state_machine.state is PlayerAttack:
		state_machine.state.attack_anim_finished()

func _on_ladder_detector_body_entered(body):
	print("enter ladder")
	ladder_map = body

func _on_ladder_detector_body_exited(_body):
	print("exit ladder")
	if state_machine.state is PlayerClimb:
		state_machine.state.exit_ladder(ladder_map)
	ladder_map = null	

func _on_ladder_detector_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	last_ladder_coord = body.get_coords_for_body_rid(body_rid)
