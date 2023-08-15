extends InteractObject

var default_data = [
	{
		"name": "Anawen",
		"message": "Can I help you?",
		"avatar": "anawen_avatar",
	 }
]

var cur_idx = 0
var data

func show_dialogue() -> void:
	cur_idx = 0
	if Globals.quests.has("main") and Globals.quests["main"] == 2:
		data = Episodes.main2()
		Globals.quests["main"] = 3
	else:
		data = default_data
	Dialogue.show_dialogue(self)
	
func get_line_data():
	if data == null or cur_idx >= data.size():
		return null
	return data[cur_idx]

func update_line_data(choice):
	cur_idx = super.default_update(data, cur_idx, choice)
