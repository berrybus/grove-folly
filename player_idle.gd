extends PlayerState

func enter(msg := {}) -> void:
	player.body_animation.play("idle")
	player.num_jumps = 0
	player.h_flip_offset = -8
	
func physics_update(delta: float) -> void:
	player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	if not player.is_on_floor():
		state_machine.transition_to("Air")
		return
	if Input.is_action_pressed("jump"):
		state_machine.transition_to("Air", { did_jump = true })
	
	if Input.is_action_just_pressed("attack"):
		state_machine.transition_to("Attack")
		
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		state_machine.transition_to("Run")

	player.move_and_slide()
