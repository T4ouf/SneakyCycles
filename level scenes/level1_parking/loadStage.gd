extends Node2D

signal launch_level()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	launch_level.emit()

