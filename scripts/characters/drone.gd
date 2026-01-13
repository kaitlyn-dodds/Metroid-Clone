extends CharacterBody2D

class_name Drone

# Animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Area2D nodes
@onready var drone_body_area: Area2D = $DroneBodyArea
@onready var detection_area: Area2D = $DetectionArea

# Health / Damage
@export var health: float = 30.0
const EXPLODE_DAMAGE: float = 30.0
var is_alive: bool = true

# Movement
const SPEED = 3000

# Target
var target: Player = null
const EXPLODE_RADIUS = 25.0
const WARN_RADIUS: float = 100.0

# Drones in proximity
var drones: Array[Drone] = []

func _ready() -> void:
	is_alive = true
	
	drone_body_area.area_entered.connect(_on_drone_body_area_entered)
	
	detection_area.body_entered.connect(_on_player_detection_area_entered)
	detection_area.body_exited.connect(_on_player_detection_area_exited)

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
	# damage player if in radius
	if target and global_position.distance_to(target.position) <= EXPLODE_RADIUS:
		# inflict damage
		target.inflict_damage(EXPLODE_DAMAGE)
	
	for drone in drones:
		if global_position.distance_to(drone.position) <= EXPLODE_RADIUS and drone:
			drone.inflict_damage(EXPLODE_DAMAGE)
			drones.erase(drone)
	
	# play death animation
	animation_player.play("explode")
	
	# wait for the death animation to play
	await animation_player.animation_finished
	queue_free()

func inflict_damage(damage: float) -> void:
	health -= damage
	
	if health <= 0:
		is_alive = false
