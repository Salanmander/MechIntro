extends Panel
class_name ModulePanel

signal drag_started

# one of these will remain null, but the same class
# used for both types
var module: Module = null
var weapon: Weapon = null
var type: String

static var pack_panel: PackedScene = load("res://Hangar/Modules/module_panel.tscn")

# module dictionary contains:
#   "effects", "weight"
#   "type": the kind of slot the module can go in
#   "name": display name
static func create_from_mod_dict(mod: Dictionary) -> ModulePanel:
	var new_panel: ModulePanel = pack_panel.instantiate()
	new_panel.type = mod["type"]
	new_panel.module = Module.create_from_dict(mod)
	new_panel.get_node("NameLabel").text = mod["name"]
	new_panel.get_node("WeightLabel").text = str(new_panel.module.weight)
	return new_panel
	

# module dictionary contains:
#   "weapon_type", "shield_dam", "armor_dam", "spread"
#   "type": the kind of slot the module can go in (always "weapon")
#   "name": display name
static func create_from_weapon_dict(weap: Dictionary) -> ModulePanel:
	var new_panel: ModulePanel = pack_panel.instantiate()
	new_panel.type = weap["type"]
	new_panel.weapon = Weapon.create_from_dict(weap)
	new_panel.get_node("NameLabel").text = weap["name"]
	new_panel.get_node("WeightLabel").text = str(new_panel.weapon.weight)
	return new_panel
	
static func create_from_module(mod: Module) -> ModulePanel:
	var new_panel: ModulePanel = pack_panel.instantiate()
	new_panel.type = mod.type
	new_panel.module = mod
	new_panel.get_node("NameLabel").text = mod.name
	new_panel.get_node("WeightLabel").text = str(mod.weight)
	return new_panel
	
static func create_from_weapon(weap: Weapon) -> ModulePanel:
	var new_panel: ModulePanel = pack_panel.instantiate()
	new_panel.type = "weapon"
	new_panel.weapon = weap
	new_panel.get_node("NameLabel").text = weap.weapon_name
	new_panel.get_node("WeightLabel").text = str(weap.weight)
	return new_panel

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	size_flags_horizontal = SIZE_SHRINK_CENTER
	
	# Border width of control this will be slotted over is 6 px
	custom_minimum_size = Vector2(Consts.MOD_PANEL_WID-12, Consts.MOD_PANEL_HGT-12)

func _get_drag_data(at_position: Vector2) -> Dictionary:
	var data_dict = get_dict()
	var preview: ModulePanel
	if type == "weapon":
		preview = create_from_weapon_dict(data_dict)
	else:
		preview = create_from_mod_dict(data_dict)
	set_drag_preview(preview)
	drag_started.emit()
	return data_dict
	



func get_dict() -> Dictionary:
	var dict = {}
	dict["type"] = type
	dict["name"] = $NameLabel.text
	if type == "weapon":
		dict["weight"] = weapon.weight
		dict["weapon_type"] = weapon.weapon_type
		dict["shield_dam"] = weapon.dam_shield
		dict["armor_dam"] = weapon.dam_armor
		dict["spread"] = weapon.spread
	else:
		dict["effects"] = module.get_effects_array()
		dict["weight"] = module.weight
	
	
	return dict
