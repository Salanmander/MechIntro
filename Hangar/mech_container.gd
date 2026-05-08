extends HBoxContainer


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mech_file: FileAccess = FileAccess.open("res://Hangar/chassis.json", FileAccess.READ)
	var mech_string: String = mech_file.get_as_text()
	var mechs = JSON.parse_string(mech_string)
	
	# mechs JSON is an array that contains dictionaries that
	# represent each mech chassis
	for mech: Dictionary in mechs:
		var new_panel: MechPanel = MechPanel.create_from_dict(mech)
		add_child(new_panel)
		


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
