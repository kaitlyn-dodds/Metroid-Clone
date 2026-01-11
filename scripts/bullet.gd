extends StaticBody2D

@export var speed: float = 500.0
var direction: Vector2

@onready var bullet_sprite: Sprite2D = $BulletSprite

func initialize(pos: Vector2, dir: Vector2) -> void:
	direction = dir
	global_position = pos
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# scale bullet from 0 to 1
	var tween = get_tree().create_tween()
	tween.tween_property(bullet_sprite, "scale", Vector2.ONE, 0.2).from(Vector2.ZERO)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
