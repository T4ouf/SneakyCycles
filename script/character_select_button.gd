extends Button

@export var char_id : int
@export var selected_count : int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	selected_count = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
