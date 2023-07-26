class_name PlayerClimb
extends PlayerState

func enter(_msg := {}) -> void:
	player.body_animation.play("climb")
	player.num_jumps = 0
	player.h_flip_offset = 0
	
func physics_update(_delta: float) -> void:
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air", { did_jump = true })
	
	var direction = Input.get_axis("ui_up", "ui_down")
	player.velocity.y = direction * 700
	if player.is_on_floor() and Input.is_action_pressed("ui_down"):
		state_machine.transition_to("Idle")
	player.move_and_slide()

func exit_ladder(ladder_map: TileMap):
	var last_tile_pos = ladder_map.map_to_local(player.last_ladder_coord)
	last_tile_pos = ladder_map.to_global(last_tile_pos)
	if player.velocity.y < 0:
		var newpos = last_tile_pos.y - ladder_map.tile_set.tile_size.y / 2 - player.get_collision_size().y / 2  - player.get_collision_offset().y - 1
		# player.global_position.y = newpos
	player.velocity.y = 0
	state_machine.transition_to("Idle")
