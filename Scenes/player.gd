extends CharacterBody2D


@export var max_speed: int = 100
@export var acceleration: int = 10
const friction: int = 8
var direction: String = "front"

@onready var detection_area: Area2D = $DetectionArea
@onready var circle := $DetectionArea/CircleRadius

@export var selectedFrequency := 0.0
@export var frequencyDistance := 50.0
@export var cone_angle_deg := 60.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	circle.shape.radius = frequencyDistance

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
	
func _check_cone() -> Array[Node2D]:
	var aim := (get_global_mouse_position() - global_position).normalized()
	
	var half_angle := deg_to_rad(cone_angle_deg) / 2.0
	
	var hits: Array[Node2D] = []
	
	for body in detection_area.get_overlapping_bodies():
		if body == self:
			continue
			
		var to_body := body.global_position - global_position
		if absf(aim.angle_to(to_body)) <= half_angle:
			hits.append(body)
	
	return hits
	
func _play_frequency() -> void:
	pass
