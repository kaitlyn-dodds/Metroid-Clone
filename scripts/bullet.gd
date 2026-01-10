extends StaticBody2D

@export var speed: float = 500.0
var direction: Vector2

func initialize(pos: Vector2, dir: Vector2) -> void:
	direction = dir
	global_position = pos
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	position += direction * speed * delta
