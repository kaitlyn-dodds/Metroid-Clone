extends Node

var should_restart: bool = false
var player_is_alive: bool = true
var transition_triggered: bool = false

var death_counter: int = 0

# Packed Scenes
@onready var level_1_scene := preload("res://scenes/levels/level_1.tscn")
@onready var restart_scene := preload("res://scenes/ui/restart.tscn")

func _ready() -> void:
	pass

func _process(_delta: float) -> void:
	pass

func on_restart_level():
	# controls what text is shown on the restart scene
	should_restart = true
	# reset
	death_counter = 0
	player_is_alive = true
	transition_triggered = false
	# change scene
	get_tree().change_scene_to_packed(level_1_scene)

func on_player_death():
	_check_transition()
	
func on_drone_death_started():
	death_counter += 1
	_check_transition()
	
func on_drone_death_finished():
	death_counter -= 1
	_check_transition()
	
func _check_transition():
	if transition_triggered:
		return # process already started
		
	if not player_is_alive and death_counter == 0:
		transition_triggered = true
		get_tree().change_scene_to_packed(restart_scene)
		
