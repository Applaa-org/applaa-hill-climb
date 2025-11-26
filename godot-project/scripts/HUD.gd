extends Control

@onready var distance_label: Label = $DistanceLabel
@onready var coins_label: Label = $CoinsLabel
@onready var fuel_bar: ProgressBar = $FuelBar
@onready var speed_label: Label = $SpeedLabel

# Mobile controls
@onready var gas_button: Button = $MobileControls/GasButton
@onready var brake_button: Button = $MobileControls/BrakeButton
@onready var left_button: Button = $MobileControls/LeftButton
@onready var right_button: Button = $MobileControls/RightButton

var player: CharacterBody2D

func _ready():
	# Hide mobile controls on desktop
	if OS.get_name() != "Android" and OS.get_name() != "iOS":
		$MobileControls.visible = false
	else:
		# Connect mobile controls
		gas_button.button_down.connect(_on_gas_pressed)
		gas_button.button_up.connect(_on_gas_released)
		brake_button.button_down.connect(_on_brake_pressed)
		brake_button.button_up.connect(_on_brake_released)
		left_button.button_down.connect(_on_left_pressed)
		left_button.button_up.connect(_on_left_released)
		right_button.button_down.connect(_on_right_pressed)
		right_button.button_up.connect(_on_right_released)

func set_player(p: CharacterBody2D):
	player = p

func _on_gas_pressed():
	if player:
		player.mobile_accelerate()

func _on_gas_released():
	if player:
		player.mobile_stop_action()

func _on_brake_pressed():
	if player:
		player.mobile_brake()

func _on_brake_released():
	if player:
		player.mobile_stop_action()

func _on_left_pressed():
	if player:
		player.mobile_tilt_left()

func _on_left_released():
	if player:
		player.mobile_stop_action()

func _on_right_pressed():
	if player:
		player.mobile_tilt_right()

func _on_right_released():
	if player:
		player.mobile_stop_action()