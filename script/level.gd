extends Node2D

@onready var players: Array[Node] = [
	$"player 1",
	$"player 2",
	$"player 3",
	$"player 4",
	$"player 5",
	$"player 6",
	$"player 7",
	$"player 8"
]

@export var stage_limits: Vector2 = Vector2(1000.0, 1000.0)

@export var trail_scene: PackedScene

var colors: Array[Color] = [
	Color.from_string("#2080C0", Color.WHITE),
	Color.from_string("#E08000", Color.WHITE),
	Color.from_string("#20A040", Color.WHITE),
	Color.from_string("#E02040", Color.WHITE),
	Color.from_string("#A060C0", Color.WHITE),
	Color.from_string("#806040", Color.WHITE),
	Color.from_string("#E080C0", Color.WHITE),
	Color.from_string("#FFFF00", Color.WHITE)
]

var trails: Array[Array] = [ # Array[Array[Area2D]]
	[], [], [], [], [], [], [], []
]

var timers: Array[Array] = [ # Array[Array[int]]
	[], [], [], [], [], [], [], []
]

# Called when the node enters the scene tree for the first time.
func _on_launch_level() -> void:
	for i: int in range(8):
		trails[i].clear()
		timers[i].clear()

	var selected_characters: Array[int] = GlobalState.selected_characters

	for i: int in range(players.size()):
		var player: Node = players[i]
		var character: CharacterData = GlobalState.characters[selected_characters[i]]
		
		GlobalState.enableNode(player)
		player.id = i
		player.is_bot = GlobalState.player_is_bot[i]
		player.score = 0
		player.health = 3 # TODO
		player.rgb_val = colors[i]
		get_node("./{0}/sprite".format([player.name])).texture = character.chromas[i]
		player.min_speed = character.min_speed / 5.
		player.max_speed = character.max_speed / 5.
		player.trail_gauge_size = character.trail_gauge_size * 100
		# TODO: steering_angle / 60 ?
		player.steering_angle = character.steering_max_angle / 60
		player.discrete_rotation = character.discrete_rotation

		#player.position.x = (i % 4) * (stage_limits.x / 4) + (stage_limits.x / 8)
		#player.position.y = (i / 4) * (stage_limits.y / 2) + (stage_limits.y / 4)
		
		player.collision_mask = (0x0001FFFF & ~(0xFFFFFFFF & (1 << player.id))) & ~(0xFFFFFFFF & (1 << (8 + player.id)))
		player.collision_layer = 1 << player.id



	
func _on_trail_dropped(player_id: int, trail_timer: float, _angle: float) -> void:
	var player_position: Vector2 = players[player_id].position

	var trail: Node = trail_scene.instantiate()
	trail.get_child(2).get_material().set_shader_parameter("color", colors[player_id])
	trail.position = player_position
	trail.get_child(0).wait_time = trail_timer
	trail.id = player_id

	add_child(trail)
	
	

func _on_damaged_enemy(player_id: int, enemy_id: int) -> void:
	players[enemy_id].health -= 1
	players[player_id].score += 1
	for player: Node in players:
		print(player.health)
