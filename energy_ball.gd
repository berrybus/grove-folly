extends Area2D

var dir: int
func _physics_process(delta):
	position.x += dir * delta * 600

func _on_timer_timeout():
	queue_free()
