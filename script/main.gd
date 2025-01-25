extends Node

@export var trail_scene : PackedScene

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta:float) -> void:
	pass

func _on_trail_dropped(player:Area2D, trail_lifespan:float, angle:float) -> void:
	var trail : Node = trail_scene.instantiate()
	trail.position = player.position#  - Vector2(10 * cos(player.rotation), 10 * sin(player.rotation)) # Wont work, I think the images are not centered
	trail.get_child(0).wait_time = trail_lifespan
	#trail.get_child(1).rotation = angle
	add_child(trail)


# TODO
func _on_player_hit()->void:
	pass
