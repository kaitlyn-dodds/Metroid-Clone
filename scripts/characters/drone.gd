extends CharacterBody2D

class_name Drone

# Animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@export var flash_decay_speed := 4.0
@onready var audio_player: AudioStreamPlayer2D = $AudioStreamPlayer2D

# Area2D nodes
@onready var drone_body_area: Area2D = $DroneBodyArea
@onready var detection_area: Area2D = $DetectionArea
@onready var sprite_2d: Sprite2D = $Sprite2D

# Health / Damage
@export var health: float = 30.0
const EXPLODE_DAMAGE: float = 60.0
var is_alive: bool = true
var is_exploding: bool = false

# Movement
const SPEED = 3000

# Target
var target: Player = null
const EXPLODE_RADIUS = 25.0
const WARN_RADIUS: float = 100.0

# Drones in proximity
var drones: Array[Drone] = []

# Signals
signal death_started
signal death_finished

func _ready() -> void:
	is_alive = true
	
	drone_body_area.area_entered.connect(_on_drone_body_area_entered)
	
	detection_area.body_entered.connect(_on_player_detection_area_entered)
	detection_area.body_exited.connect(_on_player_detection_area_exited)
	death_started.connect(GameManager.on_drone_death_started)
	death_finished.connect(GameManager.on_drone_death_finished)

func _physics_process(delta: float) -> void:
	if target and is_alive:
		# play warning "blinking" animation if getting close to player
		if global_position.distance_to(target.position) <= WARN_RADIUS:
			animation_player.play("blinking")
		
		# stop warning if player is far enough away
		if global_position.distance_to(target.position) > WARN_RADIUS:
			animation_player.play("idle")
		
		# explode if close enough to cause damage
		if global_position.distance_to(target.position) <= EXPLODE_RADIUS:
			_explode()
			
		# move toward target
		var direction = global_position.direction_to(target.position)
		velocity = direction * SPEED * delta
	else:
		# stop moving 
		velocity = Vector2.ZERO
		
	_manage_flash_decay(delta)
	
	# check if drone should die (explode)
	if not is_alive:
		_explode()
		
	move_and_slide()

func _on_drone_body_area_entered(area: Area2D) -> void:
	# is the area a bullet?
	if area.is_in_group("bullet"):
		# cast as bullet
		var bullet := area as Bullet
		
		if not bullet:
			print("ERROR: could not cast area as Bullet")
			return
		
		# apply damage
		inflict_damage(bullet.DAMAGE)
		
		# despawn bullet
		bullet.despawn()

func _on_player_detection_area_entered(body: Node2D) -> void:
	if body == self:
		return
	elif body.is_in_group("player"):
		target = body
	elif body.is_in_group("drone"):
		drones.append(body as Drone)
		
func _on_player_detection_area_exited(body: Node2D) -> void:
	if body == owner:
		return
	elif body.is_in_group("player"):
		target = null
	elif body.is_in_group("drone"):
		# remove drone from drones array
		drones.erase(body)

func _explode() -> void:
	is_alive = false
	
	if is_exploding:
		return
	
	emit_signal("death_started")
	is_exploding = true
	
	# damage player if in radius
	if target and global_position.distance_to(target.position) <= EXPLODE_RADIUS:
		# inflict damage
		target.inflict_damage(EXPLODE_DAMAGE)
		
	# play death animation
	audio_player.play()
	animation_player.play("explode")

	# wait for the death animation to play
	var animation: String = await animation_player.animation_finished
	if animation == "explode":
		emit_signal("death_finished")
		queue_free()

func chain_reaction():
	for drone in drones:
		if global_position.distance_to(drone.position) <= EXPLODE_RADIUS and drone:
			drone.inflict_damage(EXPLODE_DAMAGE)
			drones.erase(drone)

func inflict_damage(damage: float) -> void:
	health -= damage
	
	# flash the sprite when hit
	flash()
	
	if health <= 0:
		is_alive = false
		
func flash():
	sprite_2d.material.set_shader_parameter("flash_strength", 1.0)

func _manage_flash_decay(delta: float):
	var current_strength: float = sprite_2d.material.get_shader_parameter("flash_strength")
	
	if current_strength == 0.0:
		# nothing to do
		return
	
	var decayed_strength = max(current_strength - flash_decay_speed * delta, 0.0)
	sprite_2d.material.set_shader_parameter("flash_strength", decayed_strength)
