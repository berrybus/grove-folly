extends CanvasLayer

@onready var main_panel = %MainPanel
@onready var name_text = %NameText
@onready var message_text = %MessageText

@onready var timer = $Timer
@onready var avatar = $Avatar
@onready var choices_container = %ChoicesContainer

var dialogue_choice = preload("res://dialogue_choice.tscn") 
var data_provider: InteractObject
var next_choices

func _ready():
	main_panel.visible = false
	avatar.visible = false
	for choice in choices_container.get_children():
		choice.queue_free()
	Events.show_dialogue.connect(on_show_dialogue)

func _process(_delta):
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
		next_choices = line_data["choices"]

func end_dialogue():
	main_panel.visible = false
	avatar.visible = false
	timer.stop()
	# Somewhat hacky way to prevent a dialogue box from immediately opening again
	await get_tree().create_timer(0.05).timeout
	data_provider = null
	InputScheme.use_world()
	
func is_choosing():
	return choices_container.get_child_count() > 0

func _on_timer_timeout():
	if message_text.visible_ratio < 1.0:
		message_text.visible_characters += 1
	elif next_choices:
		for idx in next_choices.size():
			var choice_instance = dialogue_choice.instantiate()
			choice_instance.text = next_choices[idx]
			choice_instance.pressed.connect(func(): choose(idx))
			choices_container.add_child(choice_instance)
		choices_container.get_children().front().grab_focus()
		next_choices = null
		await get_tree().create_timer(0.05).timeout

func choose(idx):
	data_provider.update_line_data(idx)
	for choice in choices_container.get_children():
		choice.queue_free()
	next_line()
