extends Button

@export var target_scene: String

func _on_button_down() -> void:
	get_tree().change_scene_to_file("res://" + target_scene)
