extends CharacterBody2D

@export var max_speed: int = 100
@export var acceleration: int = 10
const friction: int = 8
var direction: String = "front"

const radio_texture = preload("res://assets/temp/Items/hand_radio.png")
const magnifying_glass_texture = preload("res://assets/temp/Items/magnifying_glass.png")
@onready var onhand_sprite = $OnHandSprite

@onready var detection_area: Area2D = $DetectionArea
@onready var circle := $DetectionArea/CircleRadius

@export var selectedFrequency := 0.0
@export var frequencyDistance := 50.0
@export var cone_angle_deg := 60.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	circle.shape.radius = frequencyDistance

func _physics_process(delta: float) -> void:
	queue_redraw()
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

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equip_radio"):
		onhand_sprite.texture = radio_texture
	elif event.is_action_pressed("equip_glass"):
		onhand_sprite.texture = magnifying_glass_texture

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
	for body in _check_cone():
		if body is animal2D:
			body._play_frequency_action(selectedFrequency)
			
func _draw() -> void:
	if Input.is_action_pressed("shoot"):
		var aim_angle := get_local_mouse_position().angle()
		var half := deg_to_rad(cone_angle_deg) / 2.0
		var col := Color.YELLOW

		draw_arc(Vector2.ZERO, frequencyDistance, aim_angle - half, aim_angle + half, 16, col, 1)
		draw_line(Vector2.ZERO, Vector2.from_angle(aim_angle - half) * frequencyDistance, col, 1)
		draw_line(Vector2.ZERO, Vector2.from_angle(aim_angle + half) * frequencyDistance, col, 1)
