extends CharacterBody2D


@export var max_speed: int = 100
@export var acceleration: int = 10
const friction: int = 8
var direction: String = "front"

@onready var detectioon_area: Area2D = $DetectionArea

@export var selectedFrequency := 0.0
@export var frequencyDistance := 5.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input:
		_update_direction(input)
		
	if Input.is_action_pressed("shoot"):
		_play_frequency()

	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)

	move_and_slide()

	_update_animation(input)

func _update_direction(input: Vector2) -> void:
	# Diagonals favour the side animation.
	if abs(input.x) >= abs(input.y):
		direction = "side"
		sprite.flip_h = input.x < 0
	elif input.y < 0:
		direction = "back"
	else:
		direction = "front"

func _update_animation(input: Vector2) -> void:
	var state := "walk" if input else "idle"
	sprite.play(state + "_" + direction)
	
func _check_cone(cone_angle: int) -> Array[Node2D]:
	var mouse_world := get_global_mouse_position()
	var player_to_mouse := mouse_world - position
	var direction := player_to_mouse.normalized()
	var hits: Array[Node2D] = []
	
	for body in detectioon_area.get_overlapping_bodies():
		if body == self:
			continue
	
	return hits
	
func _play_frequency() -> void:
	pass
