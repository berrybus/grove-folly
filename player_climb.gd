class_name PlayerClimb
extends PlayerState

func enter(_msg := {}) -> void:
	player.body_animation.play("climb")
	player.num_jumps = 0
	player.h_flip_offset = 0
	player.velocity.x = 0
	player.body_animation.offset.x = player.h_flip_offset
	
func physics_update(_delta: float) -> void:
	if InputScheme.is_action_just_pressed("jump"):
		start_ladder_timeout()
		state_machine.transition_to("Air", { did_jump = true })
		return
	
	var direction = InputScheme.get_axis("up", "down")
	var previous_velocity = player.velocity.y
	player.velocity.y = direction * player.LADDER_SPEED
	player.move_and_slide()
	if player.last_ladder_coord and player.ladder_map:
		var last_tile_pos = player.ladder_map.map_to_local(player.last_ladder_coord)
		last_tile_pos = player.ladder_map.to_global(last_tile_pos)
		player.global_position.x = last_tile_pos.x
	else:
		start_ladder_timeout()
		if not player.last_ladder_coord:
			print("missing ladder coord")
		if not player.ladder_map:
			print("missing ladder map")
		state_machine.transition_to("Idle")
		return
		
	if player.is_on_floor_only() and InputScheme.is_action_pressed("down"):
		start_ladder_timeout()
		state_machine.transition_to("Idle")
		return
	
	if not previous_velocity and player.velocity.y:
		player.body_animation.set_frame_and_progress(player.body_animation.frame, 1.0)
		
	if direction:
		player.body_animation.play()
	else:
		player.body_animation.pause()

func exit_ladder():
	if player.velocity.y < 0:
		player.velocity.y = player.LADDER_SPEED
	else:
		player.velocity.y = 0
	player.move_and_slide()
	start_ladder_timeout()
	state_machine.transition_to("Idle")

func start_ladder_timeout():
	player.can_enter_ladder = false
	player.ladder_timer.start()
