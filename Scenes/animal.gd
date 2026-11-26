class_name animal2D

extends CharacterBody2D

@export var journal_entry: JournalEntry

const OUTLINE_SHADER := preload("res://shaders/outline.gdshader")

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("idle")
	sprite.frame = randi() % sprite.sprite_frames.get_frame_count("idle")
	sprite.speed_scale = randf_range(0.8, 1.2)

	# Each animal gets its own material so outlines switch on independently.
	var outline := ShaderMaterial.new()
	outline.shader = OUTLINE_SHADER
	sprite.material = outline

## Shows or hides the white outline (used while the player can inspect this animal).
func set_highlighted(on: bool) -> void:
	sprite.material.set_shader_parameter("enabled", on)

func _play_frequency_action(freq: float) -> void:
	pass
