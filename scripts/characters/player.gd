extends CharacterBody2D

class_name Player

# Speed
const SPEED = 10.0
const SPEED_MULTIPLIER = 1000.0

const DECELERATION = 1000.0

#Jump
const JUMP_VELOCITY = 30.0
const JUMP_MULTIPLIER = 1000.0

# Gravity
const JUMP_GRAVITY = Vector2(0, 920.0)
const FALL_GRAVITY = Vector2(0, 500.0)


func _SPEED() -> float:
	return SPEED * SPEED_MULTIPLIER
	
func _JUMP() -> float:
	return (JUMP_VELOCITY * JUMP_MULTIPLIER) * -1

func _handle_player_movement(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if velocity.y < 0:
#			# jump gravity (applies when going up)
			velocity += JUMP_GRAVITY * delta
		else:
			# falling gravity (applies when going down)
			velocity += FALL_GRAVITY * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = _JUMP() * delta
		
	
	# Left: -1.0, Right: 1.0
	var direction := Input.get_axis("move_left", "move_right")
	
	# set velocity
	if direction:
		velocity.x = direction * _SPEED() * delta
	else:
		# slows the character down unti velocity reaches 0
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

func _physics_process(delta: float) -> void:
		
	_handle_player_movement(delta)

	

	move_and_slide()
