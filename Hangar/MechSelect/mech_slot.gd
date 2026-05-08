extends Panel
class_name MechSlot

@onready var active_stylebox:StyleBox = load("res://Hangar/Modules/module_slot_active.tres")
@onready var inactive_stylebox:StyleBox = load("res://Hangar/Modules/module_slot_inactive.tres")

const width = Consts.MECH_PANEL_WID
const height = Consts.MECH_PANEL_HGT

var type: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_stylebox_override("panel", inactive_stylebox)
	custom_minimum_size = Vector2(width, height)
	pass # Replace with function body.
	
# Location is given as a fraction of the parent control
func set_parameters(loc: Vector2, type: String) -> void:
	self.type = type
	
	anchor_bottom = loc.y
	anchor_top = loc.y
	anchor_right = loc.x
	anchor_left = loc.x
	
	offset_left = -width/2
	offset_right = width/2
	offset_top = -height/2
	offset_bottom = height/2


func clear_mech() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is MechPanel:
			child.queue_free()
			remove_child(child)
	
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) == TYPE_DICTIONARY and data.has("battle_img"):
		return true
	elif data is Mech:
		return true
	return false

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var new_panel: MechPanel
	if(typeof(data) == TYPE_DICTIONARY):
		new_panel = MechPanel.create_from_dict(data)
	else:
		new_panel = MechPanel.create_from_mech(data)
	add_child(new_panel)
	
	#Border width is 6 pixels
	new_panel.offset_left = 6
	new_panel.offset_top = 6
	
	new_panel.drag_started.connect(_on_module_dragged)
	pass


func _on_module_dragged() -> void:
	clear_mech()
