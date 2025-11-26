extends Control

var vehicle_buttons: Array = []

func _ready():
	# Create vehicle buttons
	create_vehicle_buttons()
	
	# Connect back button
	$BackButton.pressed.connect(_on_back_pressed)

func create_vehicle_buttons():
	var container = $ScrollContainer/VBoxContainer
	
	for vehicle_key in Global.vehicles.keys():
		var vehicle_data = Global.vehicles[vehicle_key]
		
		# Create button container
		var button_container = HBoxContainer.new()
		
		# Create button
		var button = Button.new()
		button.text = vehicle_data.name
		button.custom_minimum_size = Vector2(200, 50)
		
		if vehicle_data.unlocked:
			button.pressed.connect(_on_vehicle_selected.bind(vehicle_key))
			if vehicle_key == Global.current_vehicle:
				button.text += " (Selected)"
		else:
			button.text += " - %d coins" % vehicle_data.cost
			button.pressed.connect(_on_unlock_vehicle.bind(vehicle_key))
			button.disabled = Global.coins < vehicle_data.cost
		
		# Create stats label
		var stats_label = Label.new()
		var stats = Global.get_vehicle_stats(vehicle_key)
		stats_label.text = "Speed: %.0f | Fuel: %.0f" % [stats.speed, stats.fuel]
		
		button_container.add_child(button)
		button_container.add_child(stats_label)
		container.add_child(button_container)
		
		vehicle_buttons.append(button)

func _on_vehicle_selected(vehicle_key: String):
	Global.current_vehicle = vehicle_key
	Global.save_game_data()
	_on_back_pressed()

func _on_unlock_vehicle(vehicle_key: String):
	if Global.unlock_vehicle(vehicle_key):
		create_vehicle_buttons()  # Refresh buttons

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")