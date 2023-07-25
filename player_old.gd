extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -1300.0

@onready var body_animation = $BodyAnimation
@onready var sword_smear = $SwordSmear


# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity") * 4
var djump = true
var attacking = false

func _ready():
	sword_smear.stop()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y += gravity * delta

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var direction = Input.get_axis("ui_left", "ui_right")

	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if not is_on_floor():
		if djump and Input.is_action_just_pressed("jump"):
			velocity.y = JUMP_VELOCITY
			djump = false
	
	if is_on_floor():
		djump = true
	
	animate(direction)
	move_and_slide()

func animate(direction):
	if attacking:
		return
	if direction != 0:
		body_animation.play("run")
		if direction > 0:
			body_animation.flip_h = true
			body_animation.offset.x = -6
		else:
			body_animation.flip_h = false
			body_animation.offset.x = 0
	else:
		body_animation.play("idle")
	
	if not is_on_floor():
		if velocity.y >= 0:
			body_animation.play("fall")
		else:
			body_animation.play("jump")
			
	if Input.is_action_just_pressed("attack"):
		body_animation.play("attack")
		attacking = true
		sword_smear.play("attack")
		sword_smear.frame = 0
		sword_smear.flip_h = body_animation.flip_h
		if body_animation.flip_h:
			sword_smear.offset.x = 155
		else:
			sword_smear.offset.x = 0

func _on_animated_sprite_2d_animation_finished():
	if body_animation.animation == "attack":
		attacking = false
