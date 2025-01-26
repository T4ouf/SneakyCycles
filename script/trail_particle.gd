class_name TrailParticle extends StaticBody2D

var id: int

func _ready() -> void:
	$timer.start()
	collision_layer = 1
	collision_mask = 0xFF

func _on_timer_timeout() -> void:
	hide()
	queue_free()
