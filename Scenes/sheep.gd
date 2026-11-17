extends animal2D

func _play_frequency_action(freq: float) -> void:
	match freq:
		0.0:
			sprite.stop()
