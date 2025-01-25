extends Node

@export var trail_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	pass

func _on_trail_dropped(player:Area2D, trail_lifespan:float, p1:Vector2, p2:Vector2, p3:Vector2, p4:Vector2) -> void:
	var trail : Node = trail_scene.instantiate()
	trail.position = player.position
	trail.get_child(0).wait_time = trail_lifespan
	#trail.get_child(2).polygon = PackedVector2Array([p1, p2, p3, p4])
	add_child(trail)


# TODO
func _on_player_hit()->void:
	pass
