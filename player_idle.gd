class_name PlayerIdle
extends PlayerState

func enter(_msg := {}) -> void:
	player.body_animation.play("idle")
	player.num_jumps = 0
	player.h_flip_offset = -8
	
func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.FRICTION * delta)
	player.move_and_slide()
	
	if InputScheme.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		return
		
	if InputScheme.is_action_just_pressed("cast"):
		state_machine.transition_to("Attack", { "cast" = true })
		return
		
	if InputScheme.is_action_pressed("down") \
		and InputScheme.is_action_just_pressed("jump") \
		and player.can_drop_down():
		player.position.y += 1
		player.move_and_slide()
		state_machine.transition_to("Air")
		return
		
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if InputScheme.is_action_pressed("jump"):
		state_machine.transition_to("Air", { did_jump = true })
		return
		
	var direction = InputScheme.get_axis("left", "right")
	if direction:
		state_machine.transition_to("Run")
		return
	
	if player.can_climb() and InputScheme.is_action_pressed("up"):
		state_machine.transition_to("Climb")
		return
		
	if player.can_climb_down() and InputScheme.is_action_pressed("down"):
		player.will_climb_down()
		state_machine.transition_to("Climb")
		return
