extends Button

@export var target_scene: String

func _on_button_down() -> void:
	GlobalState.setMenu(target_scene)
