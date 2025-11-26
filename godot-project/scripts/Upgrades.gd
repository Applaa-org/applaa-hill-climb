extends Control

func _ready():
	# Create upgrade UI
	create_upgrade_ui()
	
	# Connect back button
	$BackButton.pressed.connect(_on_back_pressed)
	
	# Update coins display
	$CoinsLabel.text = "Coins: %d" % Global.coins

func create_upgrade_ui():
	var container = $ScrollContainer/VBoxContainer
	var vehicle_data = Global.vehicles[Global.current_vehicle]
	
	# Vehicle name
	var title = Label.new()
	title.text = "Upgrading: " + vehicle_data.name
	title.add_theme_font_size_override("font_size", 24)
	container.add_child(title)
	
	# Upgrade categories
	var upgrades = ["engine", "suspension", "tires", "fuel"]
	var upgrade_names = ["Engine", "Suspension", "Tires", "Fuel"]
	
	for i in range(upgrades.size()):
		var upgrade_type = upgrades[i]
		var upgrade_name = upgrade_names[i]
		var current_level = vehicle_data.get(upgrade_type + "_level", 1)
		
		# Create upgrade section
		var section = VBoxContainer.new()
		
		# Title
		var title_label = Label.new()
		title_label.text = upgrade_name + " (Level %d/5)" % current_level
		section.add_child(title_label)
		
		# Upgrade button
		var button = Button.new()
		if current_level < 5:
			var cost = Global.upgrade_costs[upgrade_type][current_level - 1]
			button.text = "Upgrade - %d coins" % cost
			button.pressed.connect(_on_upgrade_pressed.bind(upgrade_type))
			button.disabled = Global.coins < cost
		else:
			button.text = "MAX LEVEL"
			button.disabled = true
		
		section.add_child(button)
		container.add_child(section)

func _on_upgrade_pressed(upgrade_type: String):
	if Global.upgrade_vehicle(Global.current_vehicle, upgrade_type):
		# Refresh UI
		for child in $ScrollContainer/VBoxContainer.get_children():
			child.queue_free()
		create_upgrade_ui()
		$CoinsLabel.text = "Coins: %d" % Global.coins

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")