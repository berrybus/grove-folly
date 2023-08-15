extends Node2D

@onready var player: Player = $Player

# Called when the node enters the scene tree for the first time.
func _ready():
	player.camera_2d.limit_bottom = 640
	player.camera_2d.limit_left = -840
	player.camera_2d.limit_top = -2048
	player.camera_2d.limit_right = 4760
