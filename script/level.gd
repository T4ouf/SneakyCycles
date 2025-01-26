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
		
		player.visible = true
		player.id = i
		player.score = 0
		player.health = 3 # TODO
		player.rgb_val = colors[i]
		get_node("./{0}/sprite".format([player.name])).texture = character.chromas[i]
		player.min_speed = character.min_speed / 5.
		player.max_speed = character.max_speed / 5.
		player.trail_gauge_size = character.trail_gauge_size
		# TODO: steering_angle / 60 ?
		player.steering_angle = character.steering_max_angle / 60
		player.discrete_rotation = character.discrete_rotation

		player.position.x = (i % 4) * (stage_limits.x / 4) + (stage_limits.x / 8)
		player.position.y = (i / 4) * (stage_limits.y / 2) + (stage_limits.y / 4)
		
		player.collision_mask = 0xFF00
		player.collision_layer = 1 << player.id

		addTrail(i)



func _process(_delta: float) -> void:
	var time: int = Time.get_ticks_msec()
	for i: int in range(players.size()):
		if !timers[i].is_empty() && timers[i][0] < time:
			timers[i].pop_front()

			var current_trail: Area2D = trails[i].front()
			var shape: CollisionPolygon2D = current_trail.get_child(0)
			var polygon: PackedVector2Array = shape.polygon
			if polygon.size() == 1:
				trails[i].pop_front()
			else:
				polygon.remove_at(0)
				shape.polygon = polygon

	queue_redraw()

func _draw() -> void:
	for i: int in range(players.size()):
		for area: Area2D in trails[i]:
			var polygon: PackedVector2Array = area.get_child(0).polygon
			for j: int in range(1, polygon.size()):
				draw_line(polygon[j - 1], polygon[j], colors[i])
	

func _on_trail_dropped(player_id: int, trail_timer: int, _angle: float) -> void:
	var player_position: Vector2 = players[player_id].position
	
	var current_trail: Area2D = trails[player_id].back()
	var shape: CollisionPolygon2D = current_trail.get_child(0)
	var polygon: PackedVector2Array = shape.polygon
	polygon.push_back(player_position)
	shape.polygon = polygon
	if polygon.is_empty() || player_position.distance_to(polygon[polygon.size() - 1]) > 0.001:
		polygon.push_back(player_position)
		shape.polygon = polygon

	timers[player_id].push_back(Time.get_ticks_msec() + trail_timer)


func _on_trail_end(player_id: int) -> void:
	addTrail(player_id)


func addTrail(player_id: int) -> void:
	var trail: Area2D = Area2D.new()
	trail.collision_layer = 1 << (8 + player_id) # trail layers are layers 8 to 15
	trail.collision_mask = 0xFF # enable collisions with all the players (0 to 7)
	trail.add_child(CollisionPolygon2D.new())
	trails[player_id].push_back(trail)

func _on_damaged_enemy(player_id: int, enemy_id: int) -> void:
	players[enemy_id].health -= 1
	players[player_id].score += 1
	for player: Node in players:
		print(player.health)
