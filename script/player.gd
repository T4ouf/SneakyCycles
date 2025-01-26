extends CharacterBody2D

@export var rgb_val : Color

# Gauge consumption speed
const gauge_consumption : float = 0.5
# Gauge recharge speed
const gauge_recharge : float = 0.7
# Time (s) for gauge recharging to be available again after trailing
const gauge_cooldown : float = 2
# Minimum rotation required for charge to begin, as ratio of the unit circle
const min_drift_charge : float = 0.3 * 2 * PI

# TODO:
# - Recharging gauge
# 	- takes a small amount of time to start up : making a 1/3rd turn
# - Capturing other player entities
#	- First : A stopped trail can no longer capture someone
#	- Second : The trail can only capture if it intersects with itself

signal hit
signal trail_dropped(player_id: int, trail_timer: int,  angle: float)
signal trail_end(player_id: int)
signal damaged_enemy(player_id: int, enemy_id: int)
@onready var stage_limits : Vector2 = get_parent().stage_limits

var health : int = 3
var score : int = 0
var min_speed : float = 3
var max_speed : float = 6
# var acceleration : int = 1
var trail_lifespan : int = 2000 # time before fading, in milliseconds
# in degree
var steering_angle : float = deg_to_rad(100)
var trail_gauge_size : float = 100
var discrete_rotation : float = false
var placing_trail: bool = false

var id: int = 0
@export var is_bot : bool = false

var angle : float = 0
var speed : float = 0
var is_on_cooldown : bool = false
var drift_charge : float = 0
# 1 if turn left, -1 if turn right
var turn_direction : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	is_on_cooldown = false
	drift_charge = 0
	
	$trail_gauge.max_value = trail_gauge_size
	$trail_gauge.value = trail_gauge_size
	
	$recharge_cooldown.wait_time = gauge_cooldown
	
	$drift_particles.initial_velocity_min = 100
	$drift_particles.initial_velocity_max = 300
	$drift_particles.set_color(rgb_val)

func advance()->void:
	var movement: Vector2 = speed * Vector2.from_angle(angle)
	var collision_info: KinematicCollision2D = move_and_collide(movement, true)
	if collision_info != null:
		damaged_enemy.emit(id, collision_info.get_collider().id)
	position += movement
	position = position.clamp(Vector2.ZERO, stage_limits) # Locks the position to a domain

func turn_right()->void:
	angle += steering_angle
	$sprite.rotation = angle

	drift_charge *= int(turn_direction == -1)
	drift_charge += steering_angle
	turn_direction = -1
	recharge_trail()

func turn_left()->void:
	angle -= steering_angle
	$sprite.rotation = angle

	drift_charge *= int(turn_direction == 1)
	drift_charge += steering_angle
	turn_direction = 1
	recharge_trail()

func _on_recharge_cooldown_timeout()->void:
	is_on_cooldown = false;

func place_trail()->void:
	trail_dropped.emit(id, trail_lifespan, angle)
	$trail_gauge.value -= gauge_consumption
	is_on_cooldown = true
	placing_trail = true
	$recharge_cooldown.start()

func recharge_trail()->void:
	if not is_on_cooldown and drift_charge >= min_drift_charge:
		$trail_gauge.value += gauge_recharge

func _bot_process()->void:
	speed = (max_speed + min_speed) / 2
	turn_right()
	advance()

	# trail_dropped.emit(id, trail_lifespan, angle)
	
func _player_process()->void:
	
	var old_angle : float = angle
	
	if discrete_rotation:
		if Input.is_action_just_pressed("move_right"):
			turn_right()
		if Input.is_action_just_pressed("move_left"):
			turn_left()
			
		speed = (max_speed + min_speed) / 2
		
		if Input.is_action_just_pressed("accelerate"):
			speed = max_speed
		if Input.is_action_just_pressed("decelerate"):
			speed = min_speed

	else:
		if Input.is_action_pressed("move_right"):
			turn_right()
		if Input.is_action_pressed("move_left"):
			turn_left()
		
		speed = (max_speed + min_speed) / 2
		
		if Input.is_action_pressed("accelerate"):
			speed = max_speed
		if Input.is_action_pressed("decelerate"):
			speed = min_speed

	advance()
	
	$drift_particles.direction = Vector2.from_angle(angle + turn_direction * PI/3)
	$drift_particles.emitting = old_angle != angle

	if Input.is_action_pressed("drop_trail") and $trail_gauge.value > 0:
		place_trail()
	elif placing_trail:
		placing_trail = false
		trail_end.emit(id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if is_bot:
		_bot_process()
	else:
		_player_process()

# TODO
func _on_body_entered(body: Node2D) -> void:
	hit.emit()
