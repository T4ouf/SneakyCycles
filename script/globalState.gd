class_name GlobalState extends Node

static var characters: Array[CharacterData]

static var current_level: int

static var menus: Dictionary = {}
static var levels: Dictionary = {1:"res://level scenes/level1_parking/parking_stage.tscn"}
static var current_menu_node: String = "main menu"

static var selected_characters: Array[int]
static var player_is_bot: Array[int] = [false, true, true, true, true, true, true, true]

static func _static_init() -> void:
	loadCharacterDataFromJSON("res://gameplay scenes/characterData.json")

static func setMenu(menu_name: String) -> void:
	# var current_menu: Node = get_node(current_menu_node)
	
	var music_moment:float = 0.0;
	var musicThemePlayer:AudioStreamPlayer = menus[current_menu_node].find_child("menuThemePlayer");
	if(musicThemePlayer != null):
		music_moment = menus[current_menu_node].find_child("menuThemePlayer").get_playback_position();
		
	disableNode(menus[current_menu_node])
	current_menu_node = menu_name
	enableNode(menus[current_menu_node])
	
	musicThemePlayer = menus[current_menu_node].find_child("menuThemePlayer");
	if(musicThemePlayer != null):
		menus[current_menu_node].find_child("menuThemePlayer").play(music_moment);

static func disableNode(node: Node) -> void:
	node.visible = false
	node.process_mode = PROCESS_MODE_DISABLED

static func enableNode(node: Node) -> void:
	node.visible = true
	node.process_mode = PROCESS_MODE_INHERIT

static func loadCharacterDataFromJSON(path:String) -> void:
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	var content:String = file.get_as_text()
	
	var json:JSON = JSON.new()
	var error:Error = json.parse(content)

	if error == OK:
		var data_received:Variant = json.data
		for character:Variant in data_received.characters:
			var c: CharacterData = CharacterData.new()
			c.id = character.id
			c.character_name = character.name.replace("_", " ")
			c.min_speed = character.minSpeed
			c.max_speed = character.maxSpeed
			c.steering_max_angle = deg_to_rad(character.steeringMaxAngleDeg)
			c.trail_gauge_size = character.trailGaugeSize
			c.discrete_rotation = character.discreteRotation
			for i: int in range(8):
				c.chromas.push_back(load("res://{0}/char_{1}_alt{2}.png".format([character.textureDir, character.textureName, i])))
			characters.push_back(c)

			# set limits
			CharacterData.speed_limits = _minmaxi(CharacterData.speed_limits, c.min_speed)
			CharacterData.speed_limits = _minmaxi(CharacterData.speed_limits, c.max_speed)
			CharacterData.min_speed_limits = _minmaxi(CharacterData.min_speed_limits, c.min_speed)
			CharacterData.max_speed_limits = _minmaxi(CharacterData.max_speed_limits, c.max_speed)
			CharacterData.steering_max_angle_limits = _minmaxf(CharacterData.steering_max_angle_limits, c.steering_max_angle)
			CharacterData.trail_gauge_size_limits = _minmaxf(CharacterData.trail_gauge_size_limits, c.trail_gauge_size)
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())

		characters.push_back(CharacterData.new())

static func _minmaxi(a: Vector2i, b: int) -> Vector2i:
	return Vector2i(mini(a.x, b), maxi(a.y, b))

static func _minmaxf(a: Vector2, b: float) -> Vector2:
	return Vector2(minf(a.x, b), maxf(a.y, b))
