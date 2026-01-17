extends Node2D

# Spawn points
@onready var player_spawn_point: Marker2D = $SpawnPoints/PlayerSpawnPoint
@onready var drone_spawn_points: Node2D = $SpawnPoints/DroneSpawnPoints

# Spawned Bullets
@onready var spawned_bullets: Node2D = $SpawnedBullets

@export var PlayerScene: PackedScene
@export var BulletScene: PackedScene
@export var DroneScene: PackedScene

func _ready() -> void:
	_spawn_player()
	
	_spawn_drones()
	

func _on_player_fire_bullet(pos: Vector2, direction: Vector2) -> void:
	# spawn bullet at provided position
	var bullet := BulletScene.instantiate()
	bullet.initialize(pos, direction)
	spawned_bullets.add_child(bullet)
	
func _spawn_player():
	var player := PlayerScene.instantiate()
	player.global_position = player_spawn_point.position
	add_child(player)
	
	# connect player signals
	player.fire_bullet.connect(_on_player_fire_bullet)
	
func _spawn_drones():
	if drone_spawn_points and drone_spawn_points.get_children().size() > 0:
		for spawn_point in drone_spawn_points.get_children():
			_spawn_drone(spawn_point.position)
			
func _spawn_drone(spawn_position: Vector2):
	var drone := DroneScene.instantiate()
	drone.global_position = spawn_position
	add_child(drone)
