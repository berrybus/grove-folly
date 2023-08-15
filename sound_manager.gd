extends Node

@onready var bgm: AudioStreamPlayer = %BGM
@onready var sfx: AudioStreamPlayer = %SFX

var grove_folly = load("res://Sounds/grove_folly.ogg")
var village_of_yesterday = load("res://Sounds/village_of_yesterday.ogg")
var dreamy_path = load("res://Sounds/dreamy_path.ogg")
var hurt = load("res://Sounds/hurt.ogg")
var enemyHit = load("res://Sounds/enemyHit.ogg")
var enemyDie = load("res://Sounds/enemyDie.ogg")
var awawa = load("res://Sounds/awawa.ogg")

func _ready():
	Events.player_hit.connect(play_hurt)
	Events.change_scene.connect(play_bgm)
	bgm.stream = grove_folly
	bgm.playing = true

func play_bgm(name):
	print("playing")
	if name == "Title":
		bgm.stream = grove_folly
	elif name == "Village":
		bgm.stream = village_of_yesterday
	elif name == "HuntingGround":
		bgm.stream = dreamy_path
	bgm.playing = true

func play_hurt():
	sfx.stream = hurt
	sfx.play()

func play_hit():
	sfx.stream = enemyHit
	sfx.play()

func play_enemy_die():
	sfx.stream = enemyDie
	sfx.play()

func play_awawa():
	sfx.stream = awawa
	sfx.play()
