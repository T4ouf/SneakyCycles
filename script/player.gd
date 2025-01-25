extends Area2D

const trail_width : float = 5

signal hit
signal trail_dropped(player:Area2D, trail_timer:int,  p1:Vector2, p2:Vector2, p3:Vector2, p4:Vector2)
var screen_size : Vector2 # window size

var health : int = 3
var min_speed : float = 3
var max_speed : float = 6
# var acceleration : int = 1
var trail_lifespan : float = 2
# in degree
var steering_angle : float = 200
var trail_gauge_size : float = 0
var discrete_rotation : float = false

@export var is_bot : bool = false

var angle : float = 0
var speed : float = 0
var trail_gauge : float = 10

var last_p1 : Vector2
var last_p2 : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	screen_size  = get_viewport_rect().size
	steering_angle = deg_to_rad(steering_angle) / 60
	# hide()

func _bot_process()->void:
	speed = (max_speed + min_speed) / 2
	angle += steering_angle
	position += speed * Vector2.from_angle(angle)
	$sprite.rotation = angle
	position = position.clamp(Vector2.ZERO, screen_size) # Locks the position to a domain, here the screen dimensions

	trail_dropped.emit(self, trail_lifespan, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO, Vector2.ZERO)
	
func _player_process()->void:
	if discrete_rotation:
		if Input.is_action_just_pressed("move_right"):
			angle += steering_angle
		if Input.is_action_just_pressed("move_left"):
			angle -= steering_angle
		if Input.is_action_just_pressed("accelerate"):
			speed = max_speed
		elif Input.is_action_just_pressed("decelerate"):
			speed = min_speed
		else:
			speed = (max_speed + min_speed) / 2

	else:
		if Input.is_action_pressed("move_right"):
			angle += steering_angle
		if Input.is_action_pressed("move_left"):
			angle -= steering_angle
		if Input.is_action_pressed("accelerate"):
			speed = max_speed
		elif Input.is_action_pressed("decelerate"):
			speed = min_speed
		else:
			speed = (max_speed + min_speed) / 2

	position += speed * Vector2.from_angle(angle)
	$sprite.rotation = angle
	position = position.clamp(Vector2.ZERO, screen_size) # Locks the position to a domain, here the screen dimensions
	
	var orth_vec : Vector2 = Vector2(cos(angle + PI / 2) * trail_width / 2, sin(angle + PI /2) * trail_width / 2)
	var p1 : Vector2 = position + orth_vec
	var p2 : Vector2 = position - orth_vec

	if Input.is_action_pressed("drop_trail") and trail_gauge > 0:
		trail_dropped.emit(self, trail_lifespan, last_p1, last_p2, p2, p1)
	
	last_p1 = p1
	last_p2 = p2
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if is_bot:
		_bot_process()
	else:
		_player_process()

# TODO
func _on_body_entered(body: Node2D) -> void:
	hit.emit()

