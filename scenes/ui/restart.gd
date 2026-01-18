extends Control

@onready var restart_label: Label = $RestartLabel
@onready var main_label: Label = $MainLabel

@onready var level_one_scene := preload("res://scenes/levels/level_1.tscn")

var flicker_tween: Tween

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_flicker_restart_label()
	
	# main label should change text based on if player needs to restart
	if global.should_restart:
		main_label.text = "You Died"

func _exit_tree():
	if flicker_tween:
		flicker_tween.kill()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# restart game when user presses spacebar
	if Input.is_action_just_pressed("space"):
		print("pressed space, should restart")
		get_tree().change_scene_to_packed(level_one_scene)
		
func _flicker_restart_label():
	if flicker_tween and flicker_tween.is_running():
		flicker_tween.kill()
	
	flicker_tween = get_tree().create_tween()
	flicker_tween.set_loops() # flicker forever
	flicker_tween.tween_property(restart_label, "modulate:a", 0.0, 0.6)
	flicker_tween.tween_property(restart_label, "modulate:a", 1.0, 0.6)
