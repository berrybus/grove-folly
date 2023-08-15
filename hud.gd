extends CanvasLayer

@onready var hp = %HP
var cur_hp = 5

func _ready():
	Events.player_hit.connect(decrease_hp)
	hp.text = "HP: " + str(cur_hp)
	
func decrease_hp():
	cur_hp -= 1
	hp.text = "HP: " + str(cur_hp)
	
	if cur_hp <= 0:
		var title = load("res://title.tscn")
		SoundManager.play_awawa()
		SceneManager.goto(title, "")
