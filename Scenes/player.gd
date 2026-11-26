extends CharacterBody2D

@export var max_speed: int = 100
@export var acceleration: int = 10
const friction: int = 8
var direction: String = "front"

const radio_texture = preload("res://assets/temp/Items/hand_radio.png")
const magnifying_glass_texture = preload("res://assets/temp/Items/magnifying_glass.png")
@onready var onhand_sprite = $OnHandSprite

enum Item { GLASS, RADIO }
var equipped: Item = Item.RADIO

## Emitted whenever the held item changes
signal equipped_changed(item: Item)
signal mag_equipped(bool)

@onready var detection_area: Area2D = $DetectionArea
@onready var circle := $DetectionArea/CircleRadius

@export var selectedFrequency := 0.0
@export var frequencyDistance := 50.0
@export var cone_angle_deg := 60.0

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

# Animals currently outlined because the glass can inspect them.
var _highlighted: Array[animal2D] = []

func _ready() -> void:
	circle.shape.radius = frequencyDistance
	# Make the hand sprite match the starting item.
	equip(equipped)

func _physics_process(delta: float) -> void:
	queue_redraw()
	var input = Vector2(
		Input.get_action_strength("right") - Input.get_action_strength("left"),
		Input.get_action_strength("down") - Input.get_action_strength("up")
	).normalized()

	if input:
		_update_direction(input)
		
	if _is_using_radio():
		_play_frequency()
	
	if _is_using_mag_glass():
		for body in _check_cone():
			if body is animal2D and body.journal_entry:
				Journal.unlock(body.journal_entry.id)

	_update_highlights()

	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)

	move_and_slide()

	_update_animation(input)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("equip_radio"):
		equip(Item.RADIO)
		mag_equipped.emit(false)
	elif event.is_action_pressed("equip_glass"):
		equip(Item.GLASS)
		mag_equipped.emit(true)

func equip(item: Item) -> void:
	equipped = item
	onhand_sprite.texture = radio_texture if item == Item.RADIO else magnifying_glass_texture
	equipped_changed.emit(item)

## True while the radio is in hand and the shoot button is held.
func _is_using_radio() -> bool:
	return equipped == Item.RADIO and Input.is_action_pressed("shoot")

## True while the magnifying glass is in hand and the shoot button is held.
func _is_using_mag_glass() -> bool:
	return equipped == Item.GLASS and Input.is_action_pressed("shoot")

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
	
## Outlines every animal inside DetectionArea while the glass is equipped,
## and removes the outline from any that left range (or when the glass is put away).
func _update_highlights() -> void:
	var in_range: Array[animal2D] = []
	if equipped == Item.GLASS:
		for body in detection_area.get_overlapping_bodies():
			# Only outline animals that still have something to discover.
			if body is animal2D and body.journal_entry \
					and not Journal.is_unlocked(body.journal_entry.id):
				in_range.append(body)

	for animal in _highlighted:
		if is_instance_valid(animal) and animal not in in_range:
			animal.set_highlighted(false)
	for animal in in_range:
		if animal not in _highlighted:
			animal.set_highlighted(true)
	_highlighted = in_range

func _play_frequency() -> void:
	for body in _check_cone():
		if body is animal2D:
			body._play_frequency_action(selectedFrequency)
			
func _draw() -> void:
	if _is_using_radio():
		var aim_angle := get_local_mouse_position().angle()
		var half := deg_to_rad(cone_angle_deg) / 2.0
		var col := Color.YELLOW

		draw_arc(Vector2.ZERO, frequencyDistance, aim_angle - half, aim_angle + half, 16, col, 1)
		draw_line(Vector2.ZERO, Vector2.from_angle(aim_angle - half) * frequencyDistance, col, 1)
		draw_line(Vector2.ZERO, Vector2.from_angle(aim_angle + half) * frequencyDistance, col, 1)
