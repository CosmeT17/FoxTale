extends AnimatedSprite

func _ready():
	# object_signal.connect("signal_name", object_function, "function_name")
	connect("animation_finished", self, "_on_animation_finished")
	
	frame = 0
	play("Animate")

func _on_animation_finished():
	queue_free()
