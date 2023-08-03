class_name DamageText
extends Node2D

@onready var outline: Label = $Outline
@onready var damage: Label = $Damage
var dmg: int
func _ready():
	outline.text = str(dmg)
	damage.text = str(dmg)

func _physics_process(_delta):
	position.y -= 2

func _on_timer_timeout():
	queue_free()

