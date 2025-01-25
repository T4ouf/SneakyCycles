extends Control

@export var current_character_id: int = 0

func _ready() -> void:
	get_node("container/min speed stat").setup(CharacterData.min_speed_limits)
	get_node("container/max speed stat").setup(CharacterData.max_speed_limits)
	get_node("container/steering stat").setup(CharacterData.steering_max_angle_limits)
	get_node("container/trail size stat").setup(CharacterData.trail_gauge_size_limits)
	setCharacter(current_character_id)


func nextCharacter() -> void:
	current_character_id = (current_character_id + 1) % GlobalState.characters.size()
	setCharacter(current_character_id)

func previousCharacter() -> void:
	current_character_id -= 1
	if current_character_id < 0:
		current_character_id = GlobalState.characters.size() - 1
	setCharacter(current_character_id)

func setCharacter(id: int) -> void:
	var data: CharacterData = GlobalState.characters[id]
	
	get_node("container/thumbnail").texture = data.texture
	get_node("container/character name").text = data.character_name
	get_node("container/min speed stat").setValue(data.min_speed)
	get_node("container/max speed stat").setValue(data.max_speed)
	get_node("container/steering stat").setValue(data.steering_max_angle)
	get_node("container/trail size stat").setValue(data.trail_gauge_size)


