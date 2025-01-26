extends PanelContainer

var current_character_id: int = 0
@export var player_id: int = 0

var focused: bool = true

var focus_stylebox: StyleBoxFlat = StyleBoxFlat.new()
var default_stylebox: StyleBoxFlat
var selected_stylebox: StyleBoxFlat

var focus_neighbors: Array[NodePath] = []

func _init() -> void:
	focus_stylebox.set_border_width_all(2)
	focus_stylebox.set_expand_margin_all(2)
	focus_stylebox.set_content_margin_all(-2)
	focus_stylebox.border_color = Color.from_string("#cccccc", Color.WHITE)
	focus_stylebox.draw_center = false

	default_stylebox = focus_stylebox.duplicate()
	default_stylebox.border_color = Color.TRANSPARENT

	selected_stylebox = focus_stylebox.duplicate()
	selected_stylebox.draw_center = true
	selected_stylebox.bg_color = Color.from_string("#cccccc88", Color.WHITE)

	add_theme_stylebox_override("panel", default_stylebox)

func _ready() -> void:
	get_node("container/min speed stat").setup(CharacterData.speed_limits)
	get_node("container/max speed stat").setup(CharacterData.speed_limits)
	get_node("container/steering stat").setup(CharacterData.steering_max_angle_limits)
	get_node("container/trail size stat").setup(CharacterData.trail_gauge_size_limits)
	setCharacter(current_character_id)

	focus_neighbors = [
		focus_neighbor_left,
		focus_neighbor_right,
		focus_neighbor_top,
		focus_neighbor_bottom,
		focus_next,
		focus_previous,
	]


func _gui_input(event: InputEvent) -> void:
	if focused && event.is_action_pressed("ui_accept"):
		$container.grab_focus()
		pushFocusNeighbors()
		add_theme_stylebox_override("panel", selected_stylebox)

func _on_focus_entered() -> void:
	add_theme_stylebox_override("panel", focus_stylebox)


func _on_focus_exited() -> void:
	add_theme_stylebox_override("panel", default_stylebox)

func pushFocusNeighbors() -> void:
	focus_neighbor_left = ""
	focus_neighbor_right = ""
	focus_neighbor_top = ""
	focus_neighbor_bottom = ""
	focus_next = ""
	focus_previous = ""
	
	focused = false

func popFocusNeighbors() -> void:
	focus_neighbor_left = focus_neighbors[0]
	focus_neighbor_right = focus_neighbors[1]
	focus_neighbor_top = focus_neighbors[2]
	focus_neighbor_bottom = focus_neighbors[3]
	focus_next = focus_neighbors[4]
	focus_previous = focus_neighbors[5]

	focused = true


func nextCharacter() -> void:
	current_character_id = (current_character_id + 1) % GlobalState.characters.size()
	setCharacter(current_character_id)

func previousCharacter() -> void:
	current_character_id -= 1
	if current_character_id < 0:
		current_character_id = GlobalState.characters.size() - 1
	setCharacter(current_character_id)

func setCharacter(id: int) -> void:
	var data: CharacterData = GlobalState.characters[id]
	
	get_node("container/thumbnail").texture = data.chromas[player_id]
	get_node("container/character name").text = data.character_name
	get_node("container/min speed stat").setValue(data.min_speed)
	get_node("container/max speed stat").setValue(data.max_speed)
	get_node("container/steering stat").setValue(data.steering_max_angle)
	get_node("container/trail size stat").setValue(data.trail_gauge_size)
