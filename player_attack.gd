extends PlayerState

func enter(msg := {}) -> void:
	player.body_animation.play("attack")
	player.sword_smear.play("attack")
	player.sword_smear.frame = 0
	player.sword_smear.flip_h = player.body_animation.flip_h
	if player.body_animation.flip_h:
		player.sword_smear.offset.x = 155
	else:
		player.sword_smear.offset.x = 0
	
func physics_update(delta: float) -> void:
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction:
		player.velocity.x = direction * player.SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	
	player.velocity.y += player.gravity * delta
	player.move_and_slide()


func _on_body_animation_animation_finished():
	if player.body_animation.animation != "attack":
		return
	var direction = Input.get_axis("ui_left", "ui_right")
	if player.is_on_floor():
		if direction:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Air")
		
