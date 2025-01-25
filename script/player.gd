extends Area2D

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
signal trail_dropped(player:Area2D, trail_timer:int,  angle : float, color: Color)
var screen_size : Vector2 # window size

var health : int = 3
var min_speed : float = 3
var max_speed : float = 6
# var acceleration : int = 1
var trail_lifespan : float = 2
# in degree
var steering_angle : float = 100
var trail_gauge_size : float = 100
var discrete_rotation : float = false

@export var is_bot : bool = false

var angle : float = 0
var speed : float = 0
var is_on_cooldown : bool = false
var drift_charge : float = 0
# 1 if turn left, -1 if turn right
var turn_direction : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	screen_size  = get_viewport_rect().size
	steering_angle = deg_to_rad(steering_angle) / 60
	is_on_cooldown = false
	drift_charge = 0
	
	$trail_gauge.max_value = trail_gauge_size
	$trail_gauge.value = trail_gauge_size
	#
	
	$recharge_cooldown.wait_time = gauge_cooldown
	
	$drift_particles.initial_velocity_min = 100
	$drift_particles.initial_velocity_max = 300
	$drift_particles.set_color(rgb_val)

func advance()->void:
	position += speed * Vector2.from_angle(angle)
	position = position.clamp(Vector2.ZERO, screen_size) # Locks the position to a domain, here the screen dimensions

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
	trail_dropped.emit(self, trail_lifespan, angle, rgb_val)
	$trail_gauge.value -= gauge_consumption
	is_on_cooldown = true
	$recharge_cooldown.start()

func recharge_trail()->void:
	if not is_on_cooldown and drift_charge >= min_drift_charge:
		$trail_gauge.value += gauge_recharge

func _bot_process()->void:
	speed = (max_speed + min_speed) / 2
	turn_right()
	advance()

	trail_dropped.emit(self, trail_lifespan, angle, rgb_val)
	
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_bot:
		_bot_process()
	else:
		_player_process()

# TODO
func _on_body_entered(body: Node2D) -> void:
	hit.emit()
