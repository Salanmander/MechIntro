extends TextureRect


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mech_file: FileAccess = FileAccess.open("res://Hangar/chassis.json", FileAccess.READ)
	var mech_string: String = mech_file.get_as_text()
	var mechs = JSON.parse_string(mech_string)
	
	var slot_dicts = mechs[0]["slots"]
	for slot_dict: Dictionary in slot_dicts:
		var new_module_slot: ModuleSlot = ModuleSlot.new()
		add_child(new_module_slot)
		var pos: Array = slot_dict["pos"]
		var vec_pos: Vector2 = Vector2(pos[0],pos[1])
		new_module_slot.set_parameters(vec_pos, slot_dict["type"])
	pass # Replace with function body.


func highlight_type(type: String) -> void:
	for child: Node in get_children():
		if child is ModuleSlot:
			child.highlight_if_type(type)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
