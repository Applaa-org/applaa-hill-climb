extends CharacterBody2D

# Physics constants
const GRAVITY: float = 980.0
const MAX_SPEED: float = 400.0
const ACCELERATION: float = 150.0
const BRAKE_FORCE: float = 200.0
const ROTATION_SPEED: float = 2.0
const SUSPENSION_DAMPING: float = 0.3

# Vehicle stats
var speed: float = 200.0
var fuel: float = 100.0
var max_fuel: float = 100.0
var suspension_strength: float = 1.0

# Input states
var accelerating: bool = false
var braking: bool = false
var tilting: int = 0  # -1 for left, 0 for none, 1 for right

# Components
@onready var wheels: Array = [$FrontWheel, $RearWheel]
@onready var suspension_springs: Array = [$FrontSpring, $RearSpring]

func _ready():
	# Load vehicle stats
	var stats = Global.get_vehicle_stats(Global.current_vehicle)
	speed = stats.speed
	max_fuel = stats.fuel
	fuel = max_fuel
	suspension_strength = stats.suspension

func _physics_process(delta: float):
	# Apply gravity
	if not is_on_floor():
		velocity.y += GRAVITY * delta
	
	# Handle input
	handle_input(delta)
	
	# Apply suspension physics
	apply_suspension()
	
	# Move and slide
	move_and_slide()
	
	# Update wheel rotation
	update_wheels()
	
	# Consume fuel when accelerating
	if accelerating and fuel > 0:
		fuel -= 10 * delta
		if fuel < 0:
			fuel = 0

func handle_input(delta: float):
	# Desktop controls
	if Input.is_action_pressed("ui_up"):
		accelerating = true
		velocity.x += ACCELERATION * delta
	elif Input.is_action_pressed("ui_down"):
		braking = true
		velocity.x -= BRAKE_FORCE * delta
	else:
		accelerating = false
		braking = false
	
	# Rotation control (when in air or moving)
	if Input.is_action_pressed("ui_left"):
		tilting = -1
		rotation -= ROTATION_SPEED * delta
	elif Input.is_action_pressed("ui_right"):
		tilting = 1
		rotation += ROTATION_SPEED * delta
	else:
		tilting = 0
	
	# Limit speed
	velocity.x = clamp(velocity.x, -MAX_SPEED, MAX_SPEED)
	
	# Apply friction
	if not accelerating and not braking:
		velocity.x *= 0.98

func apply_suspension():
	# Simple suspension simulation
	for i in range(wheels.size()):
		var wheel = wheels[i]
		var spring = suspension_springs[i]
		
		# Check if wheel is on ground
		var space_state = get_world_2d().direct_space_state
		var query = PhysicsRayQueryParameters2D.create(
			wheel.global_position,
			wheel.global_position + Vector2(0, 30),
			collision_mask
		)
		var result = space_state.intersect_ray(query)
		
		if result:
			# Apply suspension force
			var compression = 1.0 - (result.position.y - wheel.global_position.y) / 30.0
			compression = clamp(compression, 0, 1)
			
			# Visual feedback
			spring.scale.y = 1.0 - compression * 0.3 * suspension_strength

func update_wheels():
	for wheel in wheels:
		# Rotate wheels based on velocity
		var rotation_speed = velocity.x / 20.0
		wheel.rotation += rotation_speed

func mobile_accelerate():
	accelerating = true

func mobile_brake():
	braking = true

func mobile_tilt_left():
	tilting = -1

func mobile_tilt_right():
	tilting = 1

func mobile_stop_action():
	accelerating = false
	braking = false
	tilting = 0

func add_fuel(amount: float):
	fuel = min(fuel + amount, max_fuel)

func is_out_of_fuel() -> bool:
	return fuel <= 0