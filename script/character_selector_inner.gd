extends VBoxContainer

@onready var parent: Node = get_parent()

func _ready() -> void:
	focus_neighbor_left = ^"."
	focus_neighbor_right = ^"."
	focus_neighbor_top = ^"."
	focus_neighbor_bottom = ^"."
	focus_next = ^"."
	focus_previous = ^"."

func _gui_input(event: InputEvent) -> void:
	# TODO: handle joystik input delay

	if event.is_action_pressed("ui_right"):
		parent.nextCharacter()
	elif event.is_action_pressed("ui_left"):
		parent.previousCharacter()
	elif event.is_action_pressed("ui_cancel") || event.is_action_pressed("ui_accept"):
		parent.grab_focus()
		parent.popFocusNeighbors()
