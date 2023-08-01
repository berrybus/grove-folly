class_name PlayerHurt
extends PlayerState

var knockback_dir: int
func enter(msg := {}) -> void:
	player.h_flip_offset = 0
	knockback_dir = msg["knockback_dir"]
	call_deferred("disable_weapon")
	player.sword_smear.stop()
	player.knockback_timer.start()
	player.body_animation.play("hurt")
	player.invuln_timer.start()
	player.modulate = Color(Color.WHITE, 0.5)

func physics_update(delta: float) -> void:
	player.velocity.x = knockback_dir * 100
	player.velocity.y += player.gravity * delta
	player.move_and_slide()

func stop_knockback():
	if player.is_on_floor():
		state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Air")

func disable_weapon():
	player.sword_collision.disabled = true
