extends Control

# Labels
@onready var restart_label: Label = $RestartLabel
@onready var main_label: Label = $MainLabel

# Preloaded scenes (TODO: change to packed scene)
@onready var level_one_scene := preload("res://scenes/levels/level_1.tscn")

# Signals
signal restart_level_1 

# Animations/Tweens
var flicker_tween: Tween

func _ready() -> void:
	_flicker_restart_label()
	
	restart_level_1.connect(GameManager.on_restart_level)
	
	# main label should change text based on if player needs to restart vs just play the game
	if GameManager.should_restart:
		main_label.text = "You Died"

func _exit_tree():
	if flicker_tween:
		flicker_tween.kill()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	# restart game when user presses spacebar
	if Input.is_action_just_pressed("space"):
		emit_signal("restart_level_1")
		
		
func _flicker_restart_label():
	if flicker_tween and flicker_tween.is_running():
		flicker_tween.kill()
	
	flicker_tween = get_tree().create_tween()
	flicker_tween.set_loops() # flicker forever
	flicker_tween.tween_property(restart_label, "modulate:a", 0.0, 0.6)
	flicker_tween.tween_property(restart_label, "modulate:a", 1.0, 0.6)
