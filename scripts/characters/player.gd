extends CharacterBody2D

class_name Player

# Reload Cooldown / Fire Rate
@onready var reload_cooldown: Timer = $ReloadCooldown
var can_fire: bool = true 

# Animations
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var legs_sprite: Sprite2D = $LegsSprite
@onready var torso_sprite: Sprite2D = $TorsoSprite
@onready var marker: Sprite2D = $Marker

signal fire_bullet(pos: Vector2, direction: Vector2)

const torso_directions = {
	Vector2i(1,0): 0,
	Vector2i(1,1): 1,
	Vector2i(0,1): 2,
	Vector2i(-1,1): 3,
	Vector2i(-1,0): 4,
	Vector2i(-1,-1): 5,
	Vector2i(0,-1): 6,
	Vector2i(1,-1): 7
}

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

# Health
var health: float = 60.0

func _ready() -> void:
	reload_cooldown.timeout.connect(_on_reload_cooldown_timeout)

func _physics_process(delta: float) -> void:
	# vertical, horizontal movement
	_handle_player_movement(delta)
	_marker_movement()
		
	# Animations
	_legs_animation()
	_torso_animation()

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
	
func _marker_movement() -> void:
	# should follow players mouse
	var mouse_position: Vector2 = get_local_mouse_position().normalized()
	marker.position = mouse_position * 40

# ANIMATION #######################################################################################

func _legs_animation() -> void: 
	if is_on_floor():
		if velocity == Vector2.ZERO:
			animation_player.play("idle")
		else:
			animation_player.play("run_animation")
			legs_sprite.flip_h = (velocity.x < 0)
	elif not is_on_floor() and velocity != Vector2.ZERO:
		animation_player.play("jump")
		legs_sprite.flip_h = (velocity.x < 0)
		
func _torso_animation() -> void:
	var mouse_position: Vector2 = get_local_mouse_position().normalized()
	var adjusted_dir: Vector2i = Vector2i(round(mouse_position.x), round(mouse_position.y))
	
	# set torso frame
	if adjusted_dir in torso_directions:
		torso_sprite.frame = torso_directions[adjusted_dir]
	else:
		print("ERROR: no torso_direction found for adjusted direction ", adjusted_dir)

func _marker_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(marker, "scale", Vector2(0.1, 0.1), 0.2)
	tween.tween_property(marker, "scale", Vector2(0.5, 0.5), 0.4)

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
		
		# Animate marker
		_marker_animation()
		
		# start cooldown
		_start_reload_cooldown()

# Health Management ###############################################################################

func inflict_damage(damage: float) -> void:
	health -= damage
	
	if health <= 0:
		print("PLayer: I am dead, game over")
		queue_free()
		
# HELPERS #########################################################################################

func _SPEED() -> float:
	return SPEED * SPEED_MULTIPLIER
	
func _JUMP() -> float:
	return (MAX_JUMP_VELOCITY * JUMP_MULTIPLIER) * -1
