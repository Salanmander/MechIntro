extends Panel
class_name MechPanel

signal drag_started

# one of these will remain null, but the same class
# used for both types
var mech: Mech = null
var dict: Dictionary = {}

static var pack_panel: PackedScene = load("res://Hangar/MechSelect/mech_panel.tscn")

# mech dictionary contains:
# "battle_img": path to top-down sprite
# "hangar_img", "slots" (not used here)
static func create_from_dict(mech_dict: Dictionary) -> MechPanel:
	var new_panel: MechPanel = pack_panel.instantiate()
	new_panel.dict = mech_dict
	new_panel.get_node("Image").texture = load(mech_dict["battle_img"])
	return new_panel
	
static func create_from_mech(mech: Mech) -> MechPanel:
	var new_panel: MechPanel = pack_panel.instantiate()
	var mech_dict = mech.get_dict()
	new_panel.dict = mech_dict
	new_panel.get_node("Image").texture = load(mech_dict["battle_img"])
	return new_panel
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size_flags_horizontal = SIZE_SHRINK_CENTER
	
	# Border width of control this will be slotted over is 6 px
	custom_minimum_size = Vector2(Consts.MECH_PANEL_WID-12, Consts.MECH_PANEL_HGT-12)

func _get_drag_data(at_position: Vector2) -> Variant:
	var preview: MechPanel = create_from_dict(dict)
	set_drag_preview(preview)
	drag_started.emit()
	if(not mech):
		var data_dict = dict.duplicate()
		return data_dict
	else:
		return mech
	
