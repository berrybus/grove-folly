class_name EnergyShot
extends Area2D

const SPEED = 500
var dir: int
var can_move = false
var player: Player

@export var particle_color: Color
@onready var animated_sprite_2d = $AnimatedSprite2D
@onready var collision_shape_2d = $CollisionShape2D

var spell_particles = preload("res://weapon_particles.tscn")

func _physics_process(delta):
	if can_move:
		position.x += dir * delta * SPEED

func _on_timer_timeout():
	play_uniform_explosion()
	queue_free()

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "start":
		can_move = true
		animated_sprite_2d.play("default")
		position.x += dir * 24

func _on_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	var other_shape_owner = area.shape_find_owner(area_shape_index)
	var other_shape_node = area.shape_owner_get_owner(other_shape_owner)
	var other_shape = area.shape_owner_get_shape(other_shape_owner, area_shape_index)
	var shape_owner = shape_find_owner(local_shape_index)
	var shape_node = shape_owner_get_owner(shape_owner)
	var shape = shape_owner_get_shape(shape_owner, local_shape_index)
	
	var points = shape.collide_and_get_contacts(
		shape_node.get_global_transform(),
		other_shape,
		other_shape_node.get_global_transform()
	)
	
	if points.size() < 2:
		print("no size")
		return
		
	var normal = (points[1] - points[0]).normalized()
	
	var particle = spell_particles.instantiate()
	particle.color = particle_color
	get_parent().add_child(particle)
	particle.emitting = true
	if normal.x > 0:
		particle.direction = Vector2(1, -1)
	else:
		particle.direction = Vector2(-1, -1)
	particle.global_position = points[0] + Vector2(0, -24)
	
	queue_free()

func get_collision_size() -> Vector2:
	return collision_shape_2d.shape.get_rect().size
	
func _on_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if not body is TileMap:
		return
	play_uniform_explosion()
	queue_free()

func play_uniform_explosion():
	var particle = spell_particles.instantiate()
	particle.color = particle_color
	get_parent().add_child(particle)
	particle.emitting = true
	particle.spread = 180
	particle.global_position = global_position
