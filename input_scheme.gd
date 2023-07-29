class_name InputScheme
extends Node

enum Scheme { WORLD, UI }

static var current_scheme: Scheme = Scheme.WORLD

static var key_map = {
		Scheme.WORLD: [
			"left",
			"right",
			"up",
			"down",
			"jump",
			"attack",
			"interact"
		],
		Scheme.UI: [
			"confirm",
			"ui_left",
			"ui_right",
			"ui_up",
			"ui_down"
		]
}

static func use_ui():
	current_scheme = Scheme.UI

static func use_world():
	current_scheme = Scheme.WORLD
	
static func is_action_just_pressed(action) -> bool:
	var allowed_actions: Array = key_map[current_scheme]
	if allowed_actions.has(action):
		return Input.is_action_just_pressed(action)
	else:
		return false

static func is_action_pressed(action) -> bool:
	var allowed_actions: Array = key_map[current_scheme]
	if allowed_actions.has(action):
		return Input.is_action_pressed(action)
	else:
		return false

static func get_axis(pos, neg) -> float:
	var allowed_actions: Array = key_map[current_scheme]
	if allowed_actions.has(pos) and allowed_actions.has(neg):
		return Input.get_axis(pos, neg)
	else:
		return 0.0
