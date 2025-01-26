class_name TrailParticle extends StaticBody2D

var id: int

func _ready() -> void:
	$timer.start()
	collision_layer = 1 << (8 + id)
	collision_mask = ~(0xFF & (1 << id))
	#collision_mask = 0x0

func _on_timer_timeout() -> void:
	hide()
	queue_free()
