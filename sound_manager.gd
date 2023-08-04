extends AudioStreamPlayer

var grove_folly = load("res://Sounds/grove_folly.ogg")
var village_of_yesterday = load("res://Sounds/village_of_yesterday.ogg")

func _enter_tree():
	get_tree().node_added.connect(_on_node_added)
	
func play_title():
	stream = grove_folly
	playing = true
	
func _on_node_added(node):
	if node.get_parent() == get_tree().root:
		print(node)
		if node.name == "Title":
			stream = grove_folly
		elif node.name == "Village":
			stream = village_of_yesterday
		playing = true
