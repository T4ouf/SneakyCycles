extends Control

var default_focus: Node

func _ready() -> void:
	default_focus = $"level 1"
	default_focus.grab_focus()

func _on_visibility_changed() -> void:
	if default_focus != null:
		default_focus.grab_focus()
