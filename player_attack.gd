class_name PlayerAttack
extends PlayerState

const DELAY_FRAMES = 3
var delay = 0

var energy_shot = preload("res://energy_shot.tscn")

func enter(msg := {}) -> void:
	if msg.has("cast"):
		cast_spell()
	else:
		use_sword()
	
func physics_update(delta: float) -> void:
	if delay == DELAY_FRAMES:
		player.sword_collision.disabled = false
	else:
		delay += 1
		
	if player.is_on_floor():
		player.velocity.x = move_toward(player.velocity.x, 0, player.ATTACK_FRICTION * delta)
	else:
		var direction = InputScheme.get_axis("left", "right")
		if direction:
			player.velocity.x = direction * player.SPEED
		else:
			player.velocity.x = move_toward(player.velocity.x, 0, player.AIR_FRICTION * delta)
	player.velocity.y += player.gravity * delta
	player.move_and_slide()

func use_sword():
	player.body_animation.play("attack")
	player.sword_smear.play("attack")
	player.sword_smear.frame = 0
	player.sword_smear.flip_h = player.body_animation.flip_h
	if player.facing_right():
		player.sword_smear.offset.x = 148
		player.sword.position.x = 72
	else:
		player.sword_smear.offset.x = 0
		player.sword.position.x = -92
	delay = 0
	
func cast_spell():
	player.body_animation.play("cast")
	var spell = energy_shot.instantiate() as EnergyShot
	spell.player = player
	player.get_owner().add_child(spell)
	spell.global_position = player.global_position + Vector2(0, 24)
	if player.facing_right():
		spell.dir = 1
		spell.position.x += 96
	else:
		spell.dir = -1
		spell.animated_sprite_2d.flip_h = true
		spell.position.x -= 96
	delay = DELAY_FRAMES + 1
	
func attack_anim_finished():
	player.sword_collision.disabled = true
	var direction = InputScheme.get_axis("left", "right")
	if player.is_on_floor():
		if direction:
			state_machine.transition_to("Run")
		else:
			state_machine.transition_to("Idle")
	else:
		state_machine.transition_to("Air")
		
