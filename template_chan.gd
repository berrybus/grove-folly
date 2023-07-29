extends InteractObject

var cur_idx = 0
var data

func show_dialogue() -> void:
	cur_idx = 0
	data = Episodes.getNames0()
	Events.show_dialogue.emit(self)
	
func get_line_data():
	if cur_idx >= data.size():
		return null
	return data[cur_idx]

func update_line_data(choice):
	cur_idx = super.default_update(data, cur_idx, choice)
