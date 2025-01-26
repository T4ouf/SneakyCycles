extends Node

func _ready() -> void:
	for node: Node in get_children():
		GlobalState.menus[node.name] = node
		node.visible = false
	
	GlobalState.menus[GlobalState.current_menu_node].visible = true
