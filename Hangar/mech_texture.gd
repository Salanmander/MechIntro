extends TextureRect

var shown_slot: MechSlot = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var mech_file: FileAccess = FileAccess.open("res://Hangar/chassis.json", FileAccess.READ)
	pass # Replace with function body.

func clear_mech() -> void:
	
	for child: Node in get_children():
		if child is ModuleSlot:
			child.queue_free()
			remove_child(child)

func show_mech(mech_slot: MechSlot) -> void:
	shown_slot = mech_slot
	var mech: Mech = mech_slot.held_panel.mech
	var mech_dict = mech.dict
	
	texture = load(mech_dict["hangar_img"])
	
	
	for child: Node in get_children():
		if child is ModuleSlot:
			child.queue_free()
			remove_child(child)
	# slot_dicts contains Dictionaries with
	#   "slot": a ModuleSlot
	#   "pos": location to display it
	var slot_dicts = mech.get_slots_with_positions()
	for slot_dict: Dictionary in slot_dicts:
		add_child(slot_dict["slot"])
		var pos: Array = slot_dict["pos"]
		var vec_pos: Vector2 = Vector2(pos[0],pos[1])
		slot_dict["slot"].place_at(vec_pos)
	pass

func highlight_type(type: String) -> void:
	for child: Node in get_children():
		if child is ModuleSlot:
			child.highlight_if_type(type)


func _notification(what: int) -> void:
	if( what == NOTIFICATION_DRAG_END ):
		if( not get_viewport().gui_is_drag_successful() ):
			if( shown_slot != null and  (not shown_slot.held_panel) ):
				shown_slot.set_inactive()
				clear_mech()
