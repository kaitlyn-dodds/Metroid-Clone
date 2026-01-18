extends Node

var should_restart: bool = false
var player_is_alive: bool = true

@onready var restart_scene := preload("res://scenes/ui/Restart.tscn")

func _ready() -> void:
	should_restart = true

func _process(delta: float) -> void:
	if not player_is_alive:
		transition_to_restart()
		
func transition_to_restart():
	player_is_alive = true
	get_tree().change_scene_to_packed(restart_scene)
