extends Control

func _ready():
	# Display stats
	$VBoxContainer/DistanceLabel.text = "Distance: %.1fm" % Global.total_distance
	$VBoxContainer/CoinsLabel.text = "Coins: %d" % Global.coins
	$VBoxContainer/HighScoreLabel.text = "High Score: %.1fm" % Global.high_score
	
	# Connect buttons
	$VBoxContainer/RetryButton.pressed.connect(_on_retry_pressed)
	$VBoxContainer/MenuButton.pressed.connect(_on_menu_pressed)
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)

func _on_retry_pressed():
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")

func _on_close_pressed():
	get_tree().quit()