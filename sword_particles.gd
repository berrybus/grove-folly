extends CPUParticles2D

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if not emitting:
		queue_free()
