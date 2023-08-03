extends PlayerState

# If we get a message asking us to jump, we jump.
func enter(msg := {}) -> void:
	if msg.has("did_jump"):
		player.velocity.y = player.JUMP_VELOCITY
		player.num_jumps += 1
	player.h_flip_offset = -8

func physics_update(delta: float) -> void:
	handle_animation()

	var direction = InputScheme.get_axis("left", "right")
	if direction:
		player.velocity.x = direction * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.AIR_FRICTION * delta)
	
	player.velocity.y += player.gravity * delta
	player.move_and_slide()
	
	if InputScheme.is_action_just_pressed("jump") and player.num_jumps < player.MAX_JUMPS and player.MAX_JUMPS > 1:
		player.velocity.y = player.JUMP_VELOCITY
		player.num_jumps += 1
	
	if InputScheme.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		return
		
	if InputScheme.is_action_just_pressed("cast"):
		state_machine.transition_to("Attack", { "cast" = true })
		return

	if player.is_on_floor():
		if direction:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
		return
		
	if player.can_climb() and InputScheme.is_action_pressed("up"):
		state_machine.transition_to("Climb")
		return

func handle_animation() -> void:
	if player.velocity.y >= 0:
		player.body_animation.play("fall")
	else:
		player.body_animation.play("jump")
