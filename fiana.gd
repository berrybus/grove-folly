extends InteractObject

var default_data = [
	{
		"name": "Fiana",
		"message": "It's a nice day today, isn't it?",
		"avatar": "fiana_avatar",
	 }
]
	
var cur_idx = 0
var data

func show_dialogue() -> void:
	cur_idx = 0
	if not Globals.quests.has("main"):
		Globals.quests["main"] = 1
		data = Episodes.main0()
	elif Globals.quests["main"] == 1 and Globals.snails_killed >= 10 and Globals.slimes_killed >= 2:
		data = Episodes.main1()
		Globals.quests["main"] = 2
	else:
		data = default_data
	Dialogue.show_dialogue(self)
	
func get_line_data():
	if data == null or cur_idx >= data.size():
		return null
	return data[cur_idx]

func update_line_data(choice):
	cur_idx = super.default_update(data, cur_idx, choice)


func _on_area_entered(area):
	if not Globals.quests.has("main"):
		show_dialogue()
