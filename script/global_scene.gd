extends Node

func _ready() -> void:
	for node: Node in get_children():
		GlobalState.menus[node.name] = node
		GlobalState.disableNode(node)
	
	GlobalState.enableNode(GlobalState.menus[GlobalState.current_menu_node])
