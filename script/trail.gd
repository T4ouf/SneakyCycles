extends RigidBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$fading_timer.start()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	

func _on_fading_timer_timeout() -> void:
	hide()
	queue_free()
