extends Control

func _ready():
	# Display final score
	$VBoxContainer/ScoreLabel.text = "Score: %d" % Global.coins
	
	# Connect buttons
	$VBoxContainer/RestartButton.pressed.connect(_on_restart_pressed)
	$VBoxContainer/MainMenuButton.pressed.connect(_on_main_menu_pressed)
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_restart_pressed():
	Global.reset_score()
	get_tree().reload_current_scene()

func _on_main_menu_pressed():
	Global.reset_score()
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()