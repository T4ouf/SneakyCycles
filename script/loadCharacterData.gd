extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	loadCharacterDataFromJSON("res://gameplay scenes/characterData.json")
	pass # Replace with function body.


func loadCharacterDataFromJSON(path:String) -> void :
	var file:FileAccess = FileAccess.open(path, FileAccess.READ)
	var content:String = file.get_as_text()
	
	var json:JSON = JSON.new()
	var error:Error = json.parse(content)
	
	if error == OK:
		var data_received:Variant = json.data
		for character:Variant in data_received.characters:
			print(character)
			
			#TODO further parse in correct dataStructure
	else:
		print("JSON Parse Error: ", json.get_error_message(), " in ", content, " at line ", json.get_error_line())
