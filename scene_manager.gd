extends CanvasLayer

@onready var animation_player = $AnimationPlayer
@onready var color_rect = $ColorRect

func _ready():
	color_rect.visible = false
	
func goto(level: PackedScene, new_door: String):
	var cur_player: Player = get_tree().get_current_scene().get_node_or_null("Player")
	var last_h_dir: bool
	if cur_player:
		last_h_dir = cur_player.body_animation.flip_h
	get_tree().paused = true
	color_rect.visible = true
	animation_player.play("fade_out")
	await animation_player.animation_finished
	get_tree().change_scene_to_packed(level)
	await get_tree().process_frame
	get_tree().paused = false
	var player: Player = get_tree().get_current_scene().get_node_or_null("Player")
	var next_door = get_tree().get_current_scene().get_node_or_null(new_door)
	if player and next_door:
		player.global_position = next_door.global_position
		player.body_animation.flip_h = last_h_dir
		player.camera_2d.reset_smoothing()
	var scene_name = get_tree().get_current_scene().name
	print(scene_name)
	Events.change_scene.emit(scene_name)
	await get_tree().process_frame
	animation_player.play("fade_in")
	await animation_player.animation_finished
	color_rect.visible = false
		
