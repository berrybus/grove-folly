extends CanvasLayer

@onready var panel = $Panel
@onready var name_text: RichTextLabel = $Panel/VBoxContainer/NameText
@onready var message_text: RichTextLabel = $Panel/VBoxContainer/MessageText
@onready var timer = $Timer
signal next_line

var dataProvider: InteractObject

var lines = [
	"Call me Ishmael.",
	"Some years ago—never mind how long precisely—having little or no money in my purse, and nothing particular to interest me on shore, I thought I would sail about a little and see the watery part of the world.",
	"It is a way I have of driving off the spleen and regulating the circulation.",
	"Whenever I find myself growing grim about the mouth;",
	"whenever it is a damp, drizzly November in my soul;",
	"whenever I find myself involuntarily pausing before coffin warehouses, and bringing up the rear of every funeral I meet;",
	"and especially whenever my hypos get such an upper hand of me, that it requires a strong moral principle to prevent me from deliberately stepping into the street, and methodically knocking people’s hats off—",
	"then, I account it high time tozz get to sea as soon as I can."
	]

var names = []
var lineIdx = 0
var charIdx = 0

func _ready():
	panel.visible = false
	Events.show_dialogue.connect(on_show_dialogue)
	for i in range(len(lines)):
		names.append("Template-Chan")

func _process(delta):
	if Input.is_action_just_pressed("ui_enter"):
		if message_text.visible_ratio == 1.0:
			lineIdx += 1
			show_line()
		else:
			message_text.visible_characters = -1
	
func on_show_dialogue(provider):
	panel.visible = true
	dataProvider = provider
	show_line()
	timer.start()

func show_line():
	if lineIdx >= lines.size():
		end_dialogue()
	name_text.text = names[lineIdx]
	message_text.text = lines[lineIdx]
	message_text.visible_characters = 0

func end_dialogue():
	dataProvider = null
	panel.visible = false
func _on_timer_timeout():
	if message_text.visible_ratio < 1.0:
		message_text.visible_characters += 1
		print(message_text.visible_characters)
