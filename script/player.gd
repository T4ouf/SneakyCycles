extends CharacterBody2D

signal game_over(id:int, other_id:int);

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
signal trail_dropped(player_id: int, trail_timer: float,  angle: float)
signal trail_end(player_id: int)
signal damaged_enemy(player_id: int, enemy_id: int)
@onready 
var stage_limits : Vector2 = get_parent().stage_limits

var health : int = 3
var score : int = 0
var min_speed : float = 3
var max_speed : float = 6
# var acceleration : int = 1
var trail_lifespan : int = 5 # time before fading, in milliseconds
# in degree
var steering_angle : float = deg_to_rad(100)
var trail_gauge_size : float = 100
var discrete_rotation : float = false
var placing_trail: bool = false

var id: int = 0
@export var is_bot : bool = false

@export var angle : float = 0
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
	
	$sprite.rotation = angle
	$hitbox.rotation = angle + PI*0.5
	#$drift_particles.initial_velocity_min = 100
	#$drift_particles.initial_velocity_max = 300

func advance()->void:
	var movement: Vector2 = speed * Vector2.from_angle(angle)
	var collision_info: KinematicCollision2D = move_and_collide(movement, true)
	if collision_info != null:
		# TODO
		print("info")
		print(collision_info.get_collider().name)
		print(collision_info.get_collider().collision_layer)
		print(collision_info.get_collider().collision_mask)
		print(name)
		print(collision_layer)
		print(collision_mask)
		
		speed = 0;
		$explosionAnimatedSprite.play("explosion")

		#GlobalState.disableNode(self)
		# if collision_info.get_collider() == self:
		# 	print("Foo")
		# damaged_enemy.emit(id, collision_info.get_collider().id)
	position += movement
	position = position.clamp(Vector2.ZERO, stage_limits) # Locks the position to a domain

func accelerate()->void:
	speed = max_speed

func decelerate()->void:
	speed = min_speed
	
func default_speed()->void:
	speed = (max_speed + min_speed) / 2

func emit_particles()->void:
	
	$drift_particles.emitting = true
	$drift_particles.direction = Vector2.from_angle(angle + turn_direction * PI/2)
	$drift_particles.initial_velocity_min = speed * 20
	$drift_particles.initial_velocity_max = speed * 40

func turn_right()->void:
	
	var old_angle : float = angle
	angle += steering_angle
	$sprite.rotation = angle
	$hitbox.rotation += steering_angle

	drift_charge *= int(turn_direction == -1)
	drift_charge += steering_angle
	turn_direction = -1

func turn_left()->void:
	
	var old_angle : float = angle
	angle -= steering_angle
	$sprite.rotation = angle
	$hitbox.rotation -= steering_angle
	
	drift_charge *= int(turn_direction == 1)
	drift_charge += steering_angle
	turn_direction = 1
	
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

#func _bot_attempt_capture(player:CharacterBody2D)->void:
#	turn_right()
#	#TODO
#
#func _bot_detect_potential_targets()->Array[CharacterBody2D]:
#	const  get_parent().players.duplicate()

func _bot_process()->void:
	turn_right()
	 #var targets = _bot_detect_potential_targets()
	
	#if has_target:
	#	_bot_attempt_capture(player)


	# trail_dropped.emit(id, trail_lifespan, angle)
	
func _player_process()->void:
	
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

	if Input.is_action_pressed("drop_trail") and $trail_gauge.value > 0:
		place_trail()
	elif placing_trail:
		placing_trail = false
		trail_end.emit(id)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	$drift_particles.emitting = false
	default_speed()
	
	if is_bot:
		_bot_process()
	else:
		_player_process()
	
	recharge_trail()
	emit_particles()
	advance()

# TODO
func _on_body_entered(body: Node2D) -> void:
	hit.emit()


func _on_visibility_changed() -> void:
	if(visible == true):
		
		#$trail_gauge.get_material().set_shader_parameter("color", rgb_val)
		var classRider:String = GlobalState.characters[GlobalState.selected_characters[id]].character_name

		if(classRider == "bicycle"):
			$drift_particles.set_color(Color("#d19b64"))
		elif(classRider == "moped"):
			$drift_particles.set_color(Color(0,0,0,1))
		elif(classRider == "scooter"):
			$drift_particles.set_color(Color(0.25,0.25,0.25, 0.7))
		elif(classRider == "moto cross"):
			$drift_particles.set_color(Color(0.25,0.25,0.25,1))
		elif(classRider == "moto basic"):
			$drift_particles.set_color(Color(0.25,0.25,0.25,1))
		elif(classRider == "moto biker"):
			$drift_particles.set_color(Color(0.25,0.25,0.25,1))
		elif(classRider == "moto GP"):
			$drift_particles.set_color(Color(0.85,0.85,0.85,0.5))
		elif(classRider == "moto tron"):
			$drift_particles.set_color(Color(0,0,0,0))



func _on_explosion_animated_sprite_animation_finished() -> void:
		self.visible = false;
		queue_free()
		get_parent().players.erase(self)
		
			
