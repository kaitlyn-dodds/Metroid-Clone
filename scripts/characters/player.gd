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
@export var flash_decay_speed := 4.0

var can_move: bool = true

signal fire_bullet(pos: Vector2, direction: Vector2)
signal player_death

@onready var torso_directions = {
	Vector2i(1,0): {
		"frame": 0,
		"bullet_spawn_point": $BulletSpawnPoints/Point0
	},
	Vector2i(1,1): {
		"frame": 1,
		"bullet_spawn_point": $BulletSpawnPoints/Point1
	},
	Vector2i(0,1): {
		"frame": 2,
		"bullet_spawn_point": $BulletSpawnPoints/Point2
	},
	Vector2i(-1,1): {
		"frame": 3,
		"bullet_spawn_point": $BulletSpawnPoints/Point3
	},
	Vector2i(-1,0): {
		"frame": 4,
		"bullet_spawn_point": $BulletSpawnPoints/Point4
	},
	Vector2i(-1,-1): {
		"frame": 5,
		"bullet_spawn_point": $BulletSpawnPoints/Point5
	},
	Vector2i(0,-1): {
		"frame": 6,
		"bullet_spawn_point": $BulletSpawnPoints/Point6
	},
	Vector2i(1,-1): {
		"frame": 7,
		"bullet_spawn_point": $BulletSpawnPoints/Point7
	}
}
var curr_torso_direction := Vector2i(1,0)

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
	can_move = true
	
	reload_cooldown.timeout.connect(_on_reload_cooldown_timeout)
	player_death.connect(GameManager.on_player_death)

func _physics_process(delta: float) -> void:
	# vertical, horizontal movement
	if can_move:
		_handle_player_movement(delta)
		_marker_movement()
			
		# Animations
		_legs_animation()
		_torso_animation()

		# shooting mechanic
		_handle_fire_input()
		
	_manage_flash_decay(delta)

	move_and_slide()

# MOVEMENT ########################################################################################

func _handle_player_movement(delta: float) -> void:
	_handle_vertical_movement(delta)
	_handle_horizontal_movement(delta)

func _handle_gravity(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		if Input.is_action_pressed("space"):
			velocity += JUMP_GRAVITY * delta
		else:
			var increment_y: float = (JUMP_GRAVITY * FALL_GRAVITY_MODIFIER * delta).y
			# cap max fall velocity 
			velocity.y = min(increment_y + velocity.y, MAX_FALL_SPEED)

func _handle_vertical_movement(delta: float) -> void:
	_handle_gravity(delta)
		
	if Input.is_action_just_pressed("space") and is_on_floor():
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
		curr_torso_direction = adjusted_dir
		torso_sprite.frame = torso_directions[adjusted_dir].frame
	else:
		print("ERROR: no torso_direction found for adjusted direction ", adjusted_dir)

func _marker_animation() -> void:
	var tween = get_tree().create_tween()
	tween.tween_property(marker, "scale", Vector2(0.1, 0.1), 0.2)
	tween.tween_property(marker, "scale", Vector2(0.5, 0.5), 0.4)

func flash():
	torso_sprite.material.set_shader_parameter("flash_strength", 1.0)
	legs_sprite.material.set_shader_parameter("flash_strength", 1.0)
	
func _manage_flash_decay(delta: float):
	var current_strength: float = torso_sprite.material.get_shader_parameter("flash_strength")
	
	if current_strength == 0.0:
		# nothing to do
		return
	
	var decayed_strength = max(current_strength - flash_decay_speed * delta, 0.0)
	torso_sprite.material.set_shader_parameter("flash_strength", decayed_strength)
	legs_sprite.material.set_shader_parameter("flash_strength", decayed_strength)

# SHOOTING ########################################################################################

func _on_reload_cooldown_timeout() -> void:
	can_fire = true
	
func _start_reload_cooldown() -> void:
	can_fire = false
	reload_cooldown.start()

func _handle_fire_input() -> void:
	if Input.is_action_just_pressed("fire") and can_fire:
		# Fire bullet
		if curr_torso_direction in torso_directions:
			var spawn_marker: Marker2D = torso_directions[curr_torso_direction].bullet_spawn_point
			fire_bullet.emit(spawn_marker.global_position, get_local_mouse_position().normalized())
		else:
			print("ERROR: Nowhere to spawn bullet")
		
		# Animate marker
		_marker_animation()
		
		# start cooldown
		_start_reload_cooldown()

# Health Management ###############################################################################

func inflict_damage(damage: float) -> void:
	health -= damage
	
	flash()
	
	if health <= 0:
		# set global player dead
		can_move = false
		GameManager.player_is_alive = false
		emit_signal("player_death")
		
# HELPERS #########################################################################################

func _SPEED() -> float:
	return SPEED * SPEED_MULTIPLIER
	
func _JUMP() -> float:
	return (MAX_JUMP_VELOCITY * JUMP_MULTIPLIER) * -1
