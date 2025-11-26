extends Control

func _ready():
	# Create map buttons
	create_map_buttons()
	
	# Connect back button
	$BackButton.pressed.connect(_on_back_pressed)

func create_map_buttons():
	var container = $VBoxContainer
	
	var maps = [
		{"name": "Forest", "scene": "Main.tscn", "gravity": 980},
		{"name": "Snow", "scene": "Main.tscn", "gravity": 800},
		{"name": "Desert", "scene": "Main.tscn", "gravity": 1000},
		{"name": "Moon", "scene": "Main.tscn", "gravity": 200}
	]
	
	for map_data in maps:
		var button = Button.new()
		button.text = map_data.name
		button.custom_minimum_size = Vector2(300, 60)
		button.pressed.connect(_on_map_selected.bind(map_data))
		container.add_child(button)

func _on_map_selected(map_data: Dictionary):
	Global.current_map = map_data.name
	# Set gravity for the map
	ProjectSettings.set_setting("physics/2d/default_gravity", map_data.gravity)
	get_tree().change_scene_to_file("res://scenes/" + map_data.scene)

func _on_back_pressed():
	get_tree().change_scene_to_file("res://scenes/StartScreen.tscn")