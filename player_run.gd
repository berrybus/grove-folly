extends PlayerState

func enter(_msg := {}) -> void:
	player.body_animation.play("run")
	player.num_jumps = 0
	player.h_flip_offset = -8

func physics_update(_delta: float) -> void:
	# Notice how we have some code duplication between states. That's inherent to the pattern,
	# although in production, your states will tend to be more complex and duplicate code
	# much more rare.
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	
	if Input.is_action_pressed("ui_down") \
		and Input.is_action_just_pressed("jump") \
		and player.can_drop_down():
		player.position.y += 1
		state_machine.transition_to("Air")
		return

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		player.velocity.x = direction * player.SPEED
	else:
		state_machine.transition_to("Idle", {did_jump = true})
		
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {did_jump = true})
	
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		
	player.move_and_slide()
