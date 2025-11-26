extends Node

# Game state
var current_vehicle: String = "car"
var coins: int = 0
var high_score: int = 0
var total_distance: float = 0.0

# Vehicle data
var vehicles: Dictionary = {
	"car": {
		"name": "Car",
		"unlocked": true,
		"engine_level": 1,
		"suspension_level": 1,
		"tires_level": 1,
		"fuel_level": 1,
		"base_speed": 200,
		"base_fuel": 100,
		"cost": 0
	},
	"jeep": {
		"name": "Jeep",
		"unlocked": false,
		"engine_level": 1,
		"suspension_level": 1,
		"tires_level": 1,
		"fuel_level": 1,
		"base_speed": 180,
		"base_fuel": 120,
		"cost": 500
	},
	"bike": {
		"name": "Bike",
		"unlocked": false,
		"engine_level": 1,
		"suspension_level": 1,
		"tires_level": 1,
		"fuel_level": 1,
		"base_speed": 250,
		"base_fuel": 80,
		"cost": 300
	},
	"truck": {
		"name": "Truck",
		"unlocked": false,
		"engine_level": 1,
		"suspension_level": 1,
		"tires_level": 1,
		"fuel_level": 1,
		"base_speed": 150,
		"base_fuel": 150,
		"cost": 1000
	}
}

# Current map
var current_map: String = "forest"

# Upgrade costs
var upgrade_costs: Dictionary = {
	"engine": [100, 200, 400, 800],
	"suspension": [80, 160, 320, 640],
	"tires": [60, 120, 240, 480],
	"fuel": [50, 100, 200, 400]
}

func _ready():
	load_game_data()

func save_game_data():
	var save_data = {
		"coins": coins,
		"high_score": high_score,
		"vehicles": vehicles,
		"current_vehicle": current_vehicle
	}
	var file = FileAccess.open("user://savegame.json", FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_game_data():
	var file = FileAccess.open("user://savegame.json", FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			var data = json.data
			coins = data.get("coins", 0)
			high_score = data.get("high_score", 0)
			vehicles = data.get("vehicles", vehicles)
			current_vehicle = data.get("current_vehicle", "car")

func add_coins(amount: int):
	coins += amount
	save_game_data()

func spend_coins(amount: int) -> bool:
	if coins >= amount:
		coins -= amount
		save_game_data()
		return true
	return false

func unlock_vehicle(vehicle_name: String) -> bool:
	if vehicles.has(vehicle_name) and not vehicles[vehicle_name].unlocked:
		var cost = vehicles[vehicle_name].cost
		if spend_coins(cost):
			vehicles[vehicle_name].unlocked = true
			save_game_data()
			return true
	return false

func upgrade_vehicle(vehicle_name: String, upgrade_type: String) -> bool:
	if not vehicles.has(vehicle_name):
		return false
	
	var vehicle = vehicles[vehicle_name]
	var current_level = vehicle.get(upgrade_type + "_level", 1)
	
	if current_level >= 5:
		return false
	
	var cost = upgrade_costs[upgrade_type][current_level - 1]
	if spend_coins(cost):
		vehicle[upgrade_type + "_level"] = current_level + 1
		save_game_data()
		return true
	return false

func get_vehicle_stats(vehicle_name: String) -> Dictionary:
	if not vehicles.has(vehicle_name):
		return {}
	
	var vehicle = vehicles[vehicle_name]
	var engine_mult = 1.0 + (vehicle.engine_level - 1) * 0.2
	var suspension_mult = 1.0 + (vehicle.suspension_level - 1) * 0.15
	var tires_mult = 1.0 + (vehicle.tires_level - 1) * 0.1
	var fuel_mult = 1.0 + (vehicle.fuel_level - 1) * 0.25
	
	return {
		"speed": vehicle.base_speed * engine_mult * tires_mult,
		"suspension": suspension_mult,
		"fuel": vehicle.base_fuel * fuel_mult
	}