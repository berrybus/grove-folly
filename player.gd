extends CharacterBody2D


const SPEED = 400.0
const JUMP_VELOCITY = -1300.0

@onready var animated_sprite_2d = $AnimatedSprite2D
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
		animated_sprite_2d.play("run")
		if direction > 0:
			animated_sprite_2d.flip_h = true
			animated_sprite_2d.offset.x = -6
		else:
			animated_sprite_2d.flip_h = false
			animated_sprite_2d.offset.x = 0
	else:
		animated_sprite_2d.play("idle")
	
	if not is_on_floor():
		if velocity.y >= 0:
			animated_sprite_2d.play("fall")
		else:
			animated_sprite_2d.play("jump")
			
	if Input.is_action_just_pressed("attack"):
		animated_sprite_2d.play("attack")
		attacking = true
		sword_smear.play("attack")
		sword_smear.frame = 0
		sword_smear.flip_h = animated_sprite_2d.flip_h
		if animated_sprite_2d.flip_h:
			sword_smear.offset.x = 155
		else:
			sword_smear.offset.x = 0

func _on_animated_sprite_2d_animation_finished():
	if animated_sprite_2d.animation == "attack":
		attacking = false
