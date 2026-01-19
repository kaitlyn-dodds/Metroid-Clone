extends AnimatableBody2D

class_name MovingPlatform

const SPEED = 30.0

@export_range(-1, 1) var horizontal_movement := 1 # negative number goes LEFT
@export_range(-1, 1) var vertical_movement := -1 # negative number goes UP

func _physics_process(delta: float) -> void:
	if horizontal_movement != 0:
		position.x += SPEED * delta * horizontal_movement
	
	if vertical_movement != 0:
		position.y += SPEED * delta * vertical_movement
	
func stop_horizontal_movement():
	horizontal_movement = 0
	
func stop_vertical_movement():
	vertical_movement = 0
	
func set_vertical_movement_to_up():
	vertical_movement = -1
	
func set_vertical_movement_to_down():
	vertical_movement = 1
	
func set_horizontal_movement_to_left():
	horizontal_movement = -1
	
func set_horizontal_movement_to_right():
	horizontal_movement = 1
	
func toggle_horizontal_movement():
	horizontal_movement = horizontal_movement * -1
	
func toggle_vertical_movement():
	vertical_movement = horizontal_movement * -1
