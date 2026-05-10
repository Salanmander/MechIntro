extends Panel
class_name ModuleSlot

@onready var active_stylebox:StyleBox = load("res://Hangar/Modules/module_slot_active.tres")
@onready var inactive_stylebox:StyleBox = load("res://Hangar/Modules/module_slot_inactive.tres")

const width = Consts.MOD_PANEL_WID
const height = Consts.MOD_PANEL_HGT

var type: String

signal contents_changed_to(new_part: ModulePanel)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_theme_stylebox_override("panel", active_stylebox)
	pass # Replace with function body.
	

func set_type(type: String) -> void:
	self.type = type

# Location is given as a fraction of the parent control
func place_at(loc: Vector2) -> void:
	anchor_bottom = loc.y
	anchor_top = loc.y
	anchor_right = loc.x
	anchor_left = loc.x
	
	offset_left = -width/2
	offset_right = width/2
	offset_top = -height/2
	offset_bottom = height/2


func clear_module() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is ModulePanel:
			child.queue_free()
			remove_child(child)
	contents_changed_to.emit(null)
	
	
func _can_drop_data(at_position: Vector2, data: Variant) -> bool:
	if typeof(data) != TYPE_DICTIONARY:
		return false
	if data.has("type") and data["type"] == type:
		return true
	return false

# data will always be a Dictionary with data["type"] == the type of this Slot
func _drop_data(at_position: Vector2, data: Variant) -> void:
	var new_panel: ModulePanel
	if(type == "weapon"):
		new_panel = ModulePanel.create_from_weapon_dict(data)
	else:
		new_panel = ModulePanel.create_from_mod_dict(data)
	set_panel(new_panel)
	contents_changed_to.emit(new_panel)
	pass

func set_panel_from_module(mod: Module) -> void:
	var new_panel: ModulePanel = ModulePanel.create_from_module(mod)
	set_panel(new_panel)
	
	
func set_panel_from_weapon(weap: Weapon) -> void:
	var new_panel: ModulePanel = ModulePanel.create_from_weapon(weap)
	set_panel(new_panel)

func set_panel(new_panel: ModulePanel) -> void:
	add_child(new_panel)
	
	#Border width is 6 pixels
	new_panel.offset_left = 6
	new_panel.offset_top = 6
	
	new_panel.drag_started.connect(_on_module_dragged)
	

func highlight_if_type(type: String) -> void:
	if(self.type == type):
		add_theme_stylebox_override("panel", active_stylebox)
	else:
		add_theme_stylebox_override("panel", inactive_stylebox)
		

func _on_module_dragged() -> void:
	clear_module()
