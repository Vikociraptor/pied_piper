extends CharacterBody2D

const max_speed: int = 100
const acceleration: int = 10
const friction: int = 8
var direction: String = "front"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _physics_process(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()

	if input:
		_update_direction(input)

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
