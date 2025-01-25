extends Button

@export var level_id: int
@export var target_scene: String

func _on_button_down() -> void:
	GlobalState.current_level = level_id
	GlobalState.setMenu(target_scene)
