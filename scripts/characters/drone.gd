extends CharacterBody2D

# Animation
@onready var animation_player: AnimationPlayer = $AnimationPlayer

# Area2D nodes
@onready var drone_body_area: Area2D = $DroneBodyArea
@onready var player_detection_area: Area2D = $PlayerDetectionArea

# Health / Damage
@export var health: float = 30.0
const EXPLODE_DAMAGE: float = 20.0
var is_alive: bool = true

# Movement
const SPEED = 30

# Target
var target: Player = null
const EXPLODE_RADIUS = 40.0

func _ready() -> void:
	is_alive = true
	
	drone_body_area.area_entered.connect(_on_drone_body_area_entered)
	
	player_detection_area.body_entered.connect(_on_player_detection_area_entered)
	player_detection_area.body_exited.connect(_on_player_detection_area_exited)

func _physics_process(delta: float) -> void:
	if target and is_alive:
		# explode if close enough to cause damage
		if global_position.distance_to(target.position) <= EXPLODE_RADIUS:
			_explode()
			
		# move toward target
		var direction = global_position.direction_to(target.position)
		velocity = direction * SPEED
	else:
		# stop moving 
		velocity = Vector2.ZERO
		
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
		health -= bullet.DAMAGE
		
		# check if drone should die
		if health <= 0:
			_explode()

func _on_player_detection_area_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = body
		
func _on_player_detection_area_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		target = null
		
func _explode() -> void:
	is_alive = false
	
	if target and global_position.distance_to(target.position) <= EXPLODE_RADIUS:
		# inflict damage
		target.inflict_damage(EXPLODE_DAMAGE)
	
	# play death animation
	animation_player.play("explode")
	
	# wait for the death animation to play
	await animation_player.animation_finished
	queue_free()
