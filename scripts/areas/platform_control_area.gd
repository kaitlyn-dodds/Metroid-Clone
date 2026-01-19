extends Area2D

@export var toggle_horizontal_movement: bool = false
@export var toggle_vertical_movement: bool = false

@export var stop_horizontal_movement: bool = false
@export var stop_vertical_movement: bool = false

@export var send_platform_down: bool = false
@export var send_platform_up: bool = false

@export var send_platform_left: bool = false
@export var send_platform_right: bool = false


func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("platform"):
		return 
		
	var platform = body as MovingPlatform
	
	if toggle_horizontal_movement:
		platform.toggle_horizontal_movement()
	
	if toggle_vertical_movement:
		platform.toggle_vertical_movement()
	
	if stop_horizontal_movement:
		platform.stop_horizontal_movement()
		
	if stop_vertical_movement:
		platform.stop_vertical_movement()

	if send_platform_down:
		platform.set_vertical_movement_to_down()
	
	if send_platform_up:
		platform.set_vertical_movement_to_up()
		
	if send_platform_left:
		platform.set_horizontal_movement_to_left()
	
	if send_platform_right:
		platform.set_horizontal_movement_to_right()
