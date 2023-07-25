class_name Player
extends CharacterBody2D

const SPEED = 400.0
const JUMP_VELOCITY = -1300.0
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 4
var num_jumps = 0
const MAX_JUMPS = 2
var h_flip_offset = 0

@onready var body_animation: AnimatedSprite2D = $BodyAnimation
@onready var sword_smear: AnimatedSprite2D = $SwordSmear
@onready var state_machine = $StateMachine

func _physics_process(delta):
	if state_machine.state.name == "Attack":
		return
	var direction = Input.get_axis("ui_left", "ui_right")
	if direction > 0:
		body_animation.flip_h = true
		body_animation.offset.x = h_flip_offset
	elif direction < 0:
		body_animation.flip_h = false
		body_animation.offset.x = 0
