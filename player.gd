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

func _ready():
	ladder_timer.stop()
	
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

func _on_body_animation_animation_finished():
	if body_animation.animation == "attack" and state_machine.state is PlayerAttack:
		state_machine.state.attack_anim_finished()

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

func _on_object_detector_area_entered(area):
	if area is InteractObject:
		touching_objects.append(area)


func _on_object_detector_area_exited(area):
	if area is InteractObject:
		touching_objects.erase(area)
