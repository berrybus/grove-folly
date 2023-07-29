class_name PlayerAttack
extends PlayerState

func enter(_msg := {}) -> void:
	player.body_animation.play("attack")
	player.sword_smear.play("attack")
	player.sword_smear.frame = 0
	player.sword_smear.flip_h = player.body_animation.flip_h
	if player.body_animation.flip_h:
		player.sword_smear.offset.x = 148
	else:
		player.sword_smear.offset.x = 0
	
func physics_update(delta: float) -> void:
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0, player.ATTACK_FRICTION * delta)
	else:
		var direction = InputScheme.get_axis("left", "right")
		if direction:
			player.velocity.x = direction * player.SPEED
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.SPEED)
	player.velocity.y += player.gravity * delta
	player.move_and_slide()


func attack_anim_finished():
	var direction = InputScheme.get_axis("left", "right")
	if player.is_on_floor():
		if direction:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Air")
		
