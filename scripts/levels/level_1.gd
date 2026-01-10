extends Node2D

@onready var player_spawn_point: Marker2D = $SpawnPoints/PlayerSpawnPoint
@onready var spawned_bullets: Node2D = $SpawnedBullets

@export var PlayerScene: PackedScene
@export var BulletScene: PackedScene

func _ready() -> void:
	var player := PlayerScene.instantiate()
	player.global_position = player_spawn_point.position
	add_child(player)
	
	# connect player signals
	player.fire_bullet.connect(_on_player_fire_bullet)
	

func _on_player_fire_bullet(pos: Vector2, direction: Vector2) -> void:
	# spawn bullet at provided position
	var bullet := BulletScene.instantiate()
	bullet.initialize(pos, direction)
	
	spawned_bullets.add_child(bullet)
