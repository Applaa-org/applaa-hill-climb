extends Node2D

# Game state
var distance: float = 0.0
var game_over: bool = false
var camera_offset: float = 0.0

# Terrain generation
var terrain_segments: Array = []
var segment_width: float = 100.0
var last_segment_x: float = 0.0

# Collectibles and obstacles
var collectibles: Array = []
var obstacles: Array = []

# References
@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera2D
@onready var terrain: Node2D = $Terrain
@onready var hud: Control = $HUD

func _ready():
	# Initialize terrain
	generate_initial_terrain()
	
	# Connect HUD to player
	hud.set_player(player)
	
	# Connect player signals
	player.connect("tree_exiting", _on_player_crashed)
	
	# Update HUD
	update_hud()

func _process(delta: float):
	if game_over:
		return
	
	# Update distance
	distance += player.velocity.x * delta / 100.0
	camera_offset += player.velocity.x * delta
	
	# Update camera position
	camera.position.x = player.position.x + 200
	
	# Generate new terrain as needed
	if camera.position.x > last_segment_x - 500:
		generate_terrain_segment()
	
	# Spawn collectibles and obstacles
	spawn_objects()
	
	# Clean up off-screen objects
	cleanup_objects()
	
	# Update HUD
	update_hud()
	
	# Check game over conditions
	check_game_over()

func generate_initial_terrain():
	# Generate starting terrain
	for i in range(20):
		generate_terrain_segment()

func generate_terrain_segment():
	var x = last_segment_x
	var height = get_terrain_height(x)
	
	# Create terrain segment
	var segment = StaticBody2D.new()
	segment.position = Vector2(x, height)
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(segment_width, 1000)
	collision.shape = shape
	segment.add_child(collision)
	
	# Visual representation
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/terrain.png")
	segment.add_child(sprite)
	
	terrain.add_child(segment)
	terrain_segments.append(segment)
	
	last_segment_x += segment_width

func get_terrain_height(x: float) -> float:
	# Procedural terrain generation using sine waves
	var height = 300.0
	height += sin(x * 0.01) * 100
	height += sin(x * 0.005) * 50
	height += sin(x * 0.02) * 30
	return height

func spawn_objects():
	# Spawn coins
	if randf() < 0.02:  # 2% chance per frame
		spawn_coin()
	
	# Spawn obstacles
	if randf() < 0.01:  # 1% chance per frame
		spawn_obstacle()
	
	# Spawn fuel
	if randf() < 0.005:  # 0.5% chance per frame
		spawn_fuel()

func spawn_coin():
	var x = camera.position.x + 800
	var y = get_terrain_height(x) - 100
	
	var coin = Area2D.new()
	coin.position = Vector2(x, y)
	coin.add_to_group("coins")
	
	var collision = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = 20
	collision.shape = shape
	coin.add_child(collision)
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/coin.png")
	coin.add_child(sprite)
	
	coin.connect("body_entered", _on_coin_collected)
	add_child(coin)
	collectibles.append(coin)

func spawn_obstacle():
	var x = camera.position.x + 800
	var y = get_terrain_height(x)
	
	var obstacle = StaticBody2D.new()
	obstacle.position = Vector2(x, y - 30)
	obstacle.add_to_group("obstacles")
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(40, 40)
	collision.shape = shape
	obstacle.add_child(collision)
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/rock.png")
	obstacle.add_child(sprite)
	
	add_child(obstacle)
	obstacles.append(obstacle)

func spawn_fuel():
	var x = camera.position.x + 800
	var y = get_terrain_height(x) - 100
	
	var fuel_can = Area2D.new()
	fuel_can.position = Vector2(x, y)
	fuel_can.add_to_group("fuel")
	
	var collision = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(30, 40)
	collision.shape = shape
	fuel_can.add_child(collision)
	
	var sprite = Sprite2D.new()
	sprite.texture = preload("res://assets/fuel.png")
	fuel_can.add_child(sprite)
	
	fuel_can.connect("body_entered", _on_fuel_collected)
	add_child(fuel_can)
	collectibles.append(fuel_can)

func _on_coin_collected(body):
	if body == player:
		Global.add_coins(10)
		var coin = body.get_overlapping_areas()[0]
		collectibles.erase(coin)
		coin.queue_free()

func _on_fuel_collected(body):
	if body == player:
		player.add_fuel(30)
		var fuel = body.get_overlapping_areas()[0]
		collectibles.erase(fuel)
		fuel.queue_free()

func cleanup_objects():
	# Remove off-screen objects
	for coin in collectibles:
		if coin.position.x < camera.position.x - 400:
			collectibles.erase(coin)
			coin.queue_free()
	
	for obstacle in obstacles:
		if obstacle.position.x < camera.position.x - 400:
			obstacles.erase(obstacle)
			obstacle.queue_free()

func update_hud():
	hud.get_node("DistanceLabel").text = "Distance: %.1fm" % distance
	hud.get_node("CoinsLabel").text = "Coins: %d" % Global.coins
	hud.get_node("FuelBar").value = (player.fuel / player.max_fuel) * 100
	hud.get_node("SpeedLabel").text = "Speed: %.0f" % abs(player.velocity.x)

func check_game_over():
	if player.is_out_of_fuel():
		end_game("Out of Fuel!")
	
	# Check if player flipped over
	if abs(player.rotation) > PI/2:
		end_game("Crashed!")

func end_game(reason: String):
	game_over = true
	Global.total_distance = distance
	
	if distance > Global.high_score:
		Global.high_score = distance
		Global.save_game_data()
	
	# Show game over screen
	get_tree().change_scene_to_file("res://scenes/GameOver.tscn")

func _on_player_crashed():
	end_game("Crashed!")