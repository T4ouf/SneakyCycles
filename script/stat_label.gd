extends Control

@export var stat_name: String
# var stat_min: float
# var stat_max: float

func setup(limits: Vector2) -> void:
	get_node("container/stat name").text = stat_name

	var bar: ProgressBar = get_node("container/stat value")
	bar.min_value = limits.x
	bar.max_value = limits.y

func setValue(value: float) -> void:
	get_node("container/stat value").value = value
