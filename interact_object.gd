class_name InteractObject
extends Area2D

func show_dialogue() -> void:
	Events.show_dialogue.emit(self)
