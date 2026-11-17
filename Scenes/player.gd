extends CharacterBody2D

const max_speed: int = 100
const acceleration: int = 10
const friction: int = 8

func _physics_process(delta: float) -> void:
	var input = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	).normalized()
	
	if input:
		$Player.flip_h = true if input.x < 0 else false
	else:
		pass
	
	var lerp_weight = delta * (acceleration if input else friction)
	velocity = lerp(velocity, input * max_speed, lerp_weight)
	
	move_and_slide()
