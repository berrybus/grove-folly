extends PlayerState

func enter(_msg := {}) -> void:
	player.body_animation.play("run")
	player.num_jumps = 0
	player.h_flip_offset = -8

func physics_update(_delta: float) -> void:	
	if Input.is_action_pressed("ui_down") \
		and Input.is_action_just_pressed("jump") \
		and player.can_drop_down():
		player.position.y += 1
		state_machine.transition_to("Air")
		return

	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		player.velocity.x = player.SPEED * direction
		player.move_and_slide()
	else:
		state_machine.transition_to("Idle")
		return
	
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
		
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Air", {did_jump = true})
		return
	
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		return
		
	if player.can_climb() and Input.is_action_pressed("ui_up"):
		state_machine.transition_to("Climb")
		return
	
	if player.can_climb_down() and Input.is_action_pressed("ui_down"):
		player.will_climb_down()
		state_machine.transition_to("Climb")
		return
