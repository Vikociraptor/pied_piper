class_name animal2D

extends CharacterBody2D


@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("idle")
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("idle")
	sprite.speed_scale = randf_range(0.8, 1.2)

func _play_frequency_action(freq: float) -> void:
	pass
