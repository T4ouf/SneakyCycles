extends VBoxContainer

@onready var parent: Node = get_parent()

func _ready() -> void:
	focus_neighbor_left = ^"."
	focus_neighbor_right = ^"."
	focus_neighbor_top = ^"."
	focus_neighbor_bottom = ^"."
	focus_next = ^"."
	focus_previous = ^"."

	if GlobalState.player_is_bot[parent.player_id]:
		$"player type".text = "Bot"
	else:
		$"player type".text = "Player %d" % (parent.player_id + 1)

func _gui_input(event: InputEvent) -> void:
	# TODO: handle joystik input delay

	if event.is_action_pressed("ui_right"):
		parent.nextCharacter()
	elif event.is_action_pressed("ui_left"):
		parent.previousCharacter()
	elif event.is_action_pressed("ui_select"):
		if GlobalState.player_is_bot[parent.player_id]:
			$"player type".text = "Player %d" % (parent.player_id + 1)
			GlobalState.player_is_bot[parent.player_id] = false
		else:
			$"player type".text = "Bot"
			GlobalState.player_is_bot[parent.player_id] = true
	elif event.is_action_pressed("ui_cancel") || event.is_action_pressed("ui_accept"):
		parent.grab_focus()
		parent.popFocusNeighbors()
