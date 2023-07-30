extends CanvasLayer

@onready var main_panel = %MainPanel
@onready var name_text = %NameText
@onready var message_text = %MessageText
@onready var choice_0 = %Choice0
@onready var choice_1 = %Choice1
@onready var choice_2 = %Choice2

@onready var timer = $Timer
@onready var avatar = $Avatar

@onready var choices = [choice_0, choice_1, choice_2]

var data_provider: InteractObject
var avatarMap
var next_choices

func _ready():
	main_panel.visible = false
	avatar.visible = false
	Events.show_dialogue.connect(on_show_dialogue)
	for choice in choices:
		choice.hide()

func _process(delta):
	if data_provider == null:
		return
	if InputScheme.is_action_just_pressed("confirm"):
		if message_text.visible_ratio == 1.0:
			if not next_choices and not is_choosing():
				data_provider.update_line_data(-1)
				next_line()
		elif message_text.visible_ratio < 1.0:
			message_text.visible_characters = -1
	
func on_show_dialogue(provider):
	if data_provider:
		return
	InputScheme.use_ui()
	main_panel.visible = true
	avatar.visible = true
	data_provider = provider
	timer.start()
	next_line()

func next_line():
	var line_data = data_provider.get_line_data()
	if not line_data:
		end_dialogue()
		return
	var avatar_texture = null
	if line_data.has("avatar"):
		avatar_texture = load("res://Avatars/" + line_data["avatar"] + ".png")
		avatar.texture = avatar_texture
	else:
		avatar.texture = null
	name_text.text = line_data["name"]
	message_text.text = line_data["message"]
	message_text.visible_characters = 0
	
	if line_data.has("choices"):
		var message_choices = line_data["choices"]
		next_choices = message_choices

func end_dialogue():
	main_panel.visible = false
	avatar.visible = false
	timer.stop()
	# Somewhat hacky way to prevent a dialogue box from immediately opening again
	await get_tree().create_timer(0.05).timeout
	data_provider = null
	InputScheme.use_world()
	
func is_choosing():
	for choice in choices:
		if choice.visible == true:
			return true
	return false

func _on_timer_timeout():
	if message_text.visible_ratio < 1.0:
		message_text.visible_characters += 1
	elif next_choices:
		for idx in next_choices.size():
			if idx < choices.size():
				var button: Button = choices[idx]
				button.show()
				button.text = next_choices[idx]
			choice_0.grab_focus()
		next_choices = null
		await get_tree().create_timer(0.05).timeout

func _on_choice_0_pressed():
	choose(0)

func _on_choice_1_pressed():
	choose(1)

func _on_choice_2_pressed():
	choose(1)

func choose(idx):
	data_provider.update_line_data(idx)
	for choice in choices:
		choice.hide()
	next_line()
