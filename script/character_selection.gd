extends Control

var default_focus: Node

signal launch_level()

func _ready() -> void:
	default_focus = $"MarginContainer/container/character 1"
	default_focus.grab_focus()


func _on_visibility_changed() -> void:
	if default_focus != null:
		default_focus.grab_focus()


func _on_start_game_button_pressed() -> void:
	GlobalState.selected_characters = [
		$"MarginContainer/container/character 1".current_character_id,
		$"MarginContainer/container/character 2".current_character_id,
		$"MarginContainer/container/character 3".current_character_id,
		$"MarginContainer/container/character 4".current_character_id,
		$"MarginContainer/container/character 5".current_character_id,
		$"MarginContainer/container/character 6".current_character_id,
		$"MarginContainer/container/character 7".current_character_id,
		$"MarginContainer/container/character 8".current_character_id
	]

	
	get_tree().change_scene_to_file(GlobalState.levels[GlobalState.current_level])

