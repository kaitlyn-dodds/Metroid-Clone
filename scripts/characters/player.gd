extends CharacterBody2D

class_name Player

# Reload Cooldown / Fire Rate
@onready var reload_cooldown: Timer = $ReloadCooldown
var can_fire: bool = true 

signal fire_bullet(pos: Vector2, direction: Vector2)

# Speed
const SPEED = 12.0
const SPEED_MULTIPLIER = 1000.0
const DECELERATION = 1000.0

#Jump
const MAX_JUMP_VELOCITY = 30.0
const JUMP_MULTIPLIER = 1000.0
const MAX_FALL_SPEED = 500.0

# Gravity
const JUMP_GRAVITY = Vector2(0, 1200.0)
const FALL_GRAVITY_MODIFIER = 2.0

func _ready() -> void:
	reload_cooldown.timeout.connect(_on_reload_cooldown_timeout)

func _physics_process(delta: float) -> void:
	# vertical, horizontal movement
	_handle_player_movement(delta)

	# shooting mechanic
	_handle_fire_input()

	move_and_slide()

# MOVEMENT ########################################################################################

func _handle_player_movement(delta: float) -> void:
	_handle_vertical_movement(delta)
	_handle_horizontal_movement(delta)

func _handle_gravity(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("jump"):
			velocity += JUMP_GRAVITY * delta
		else:
			var increment_y: float = (JUMP_GRAVITY * FALL_GRAVITY_MODIFIER * delta).y
			# cap max fall velocity 
			velocity.y = min(increment_y + velocity.y, MAX_FALL_SPEED)

func _handle_vertical_movement(delta: float) -> void:
	_handle_gravity(delta)
		
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = _JUMP() * delta

func _handle_horizontal_movement(delta: float) -> void:
	# Left: -1.0, Right: 1.0
	var direction := Input.get_axis("move_left", "move_right")
	
	# set velocity
	if direction:
		velocity.x = direction * _SPEED() * delta
	else:
		# slows the character down unti velocity reaches 0
		velocity.x = move_toward(velocity.x, 0, DECELERATION * delta)

# SHOOTING ########################################################################################

func _on_reload_cooldown_timeout() -> void:
	can_fire = true
	
func _start_reload_cooldown() -> void:
	can_fire = false
	reload_cooldown.start()

func _handle_fire_input() -> void:
	if Input.is_action_just_pressed("fire") and can_fire:
		# Fire bullet
		fire_bullet.emit(position, get_local_mouse_position().normalized())
		
		# start cooldown
		_start_reload_cooldown()
		
# HELPERS #########################################################################################

func _SPEED() -> float:
	return SPEED * SPEED_MULTIPLIER
	
func _JUMP() -> float:
	return (MAX_JUMP_VELOCITY * JUMP_MULTIPLIER) * -1
