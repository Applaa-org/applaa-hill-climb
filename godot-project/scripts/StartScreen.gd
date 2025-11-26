extends Control

func _ready():
	# Connect button signals
	$VBoxContainer/PlayButton.pressed.connect(_on_play_pressed)
	$VBoxContainer/VehicleButton.pressed.connect(_on_vehicle_pressed)
	$VBoxContainer/UpgradesButton.pressed.connect(_on_upgrades_pressed)
	$VBoxContainer/CloseButton.pressed.connect(_on_close_pressed)
	
	# Update coins display
	$CoinsLabel.text = "Coins: %d" % Global.coins

func _on_play_pressed():
	get_tree().change_scene_to_file("res://scenes/MapSelect.tscn")

func _on_vehicle_pressed():
	get_tree().change_scene_to_file("res://scenes/VehicleSelect.tscn")

func _on_upgrades_pressed():
	get_tree().change_scene_to_file("res://scenes/Upgrades.tscn")

func _on_close_pressed():
	get_tree().quit()