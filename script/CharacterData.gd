class_name CharacterData extends Node

@export var id: int = -1
@export var character_name: String = "default"
@export var min_speed: int = 10
@export var max_speed: int = 15
@export var steering_max_angle: float = 70
@export var trail_gauge_size: float = 200
@export var discrete_rotation: bool = false
var chromas: Array[Texture2D] = []

static var speed_limits: Vector2i
static var min_speed_limits: Vector2i
static var max_speed_limits: Vector2i
static var steering_max_angle_limits: Vector2
static var trail_gauge_size_limits: Vector2
