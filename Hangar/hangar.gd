extends Control


func _ready() -> void:
	$Squad/MechContainer.add_child(MechSlot.new())
	$Squad/MechContainer.add_child(MechSlot.new())
	$Squad/MechContainer.add_child(MechSlot.new())
	
	var mods_file: FileAccess = FileAccess.open("res://Hangar/Modules/modules.json", FileAccess.READ)
	var mods_string: String = mods_file.get_as_text()
	var mods: Array = JSON.parse_string(mods_string)
	
	# mods is an array of dictionaries
	# Each dictionary contains info about a single module
	for mod: Dictionary in mods:
		add_module_from_dict(mod)
	
	highlight_for_tab($ModuleSelect.current_tab)
	

# A module dictionary contains:
#   "type": will be "weapon", "leg", or "core"
#      weapon is handled differently than the other two,
#      so using separate method for them
#
#   non-weapon modules contain:
#   "name": String with display name
#   "effects": Array of dictionaries, each dictionary contains
#      "type": "shield", "accuracy", or "speed"
#      "val": number representing the amount of that effect
#   "weight": weight of the module
func add_module_from_dict(mod) -> void:
	if( mod["type"] == "weapon" ):
		add_weapon_from_dict(mod)
		return
	
	var new_panel: ModulePanel = ModulePanel.create_from_mod_dict(mod)
	if( mod["type"] == "core" ):
		$ModuleSelect/Core.add_child(new_panel)
		
	if( mod["type"] == "leg" ):
		$ModuleSelect/Legs.add_child(new_panel)
	
	pass


#   weapon modules contain:
#   "name": display name
#   "weight": module weight
#   used by weapon constructor:
#   "weapon type", "shield_dam", "armor_dam", "spread"
func add_weapon_from_dict(mod) -> void:
	var new_panel: ModulePanel = ModulePanel.create_from_weapon_dict(mod)
	$ModuleSelect/Weapons.add_child(new_panel)
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func highlight_for_tab(tab: int) -> void:
	var type: String = $ModuleSelect.get_tab_title(tab)
	type = type.to_lower()
	if(type.ends_with("s")):
		type = type.erase(type.length() - 1, 1)
	$Design/MechTexture.highlight_type(type)

func _on_module_select_tab_changed(tab: int) -> void:
	highlight_for_tab(tab)
	pass # Replace with function body.
