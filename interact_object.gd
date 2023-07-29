class_name InteractObject
extends Area2D
	
func show_dialogue() -> void:
	pass

func get_line_data():
	return {}

func update_line_data(choice) -> void:
	pass

func default_update(data, cur_idx, choice) -> int:
	var line = data[cur_idx]
	if choice >= 0 and line.has("choice_jumps"):
		var options = line["choice_jumps"]
		if choice < options.size():
			return options[choice]
	if line.has("jump"):
		var jumpto = line["jump"]
		if jumpto == -1:
			return data.size() + 1
		else:
			return jumpto
	else:
		return cur_idx + 1
