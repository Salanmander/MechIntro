extends Area2D
class_name Mech

static var pack_mech: PackedScene = load("res://Battlefield/Mech/mech.tscn")

# Holds the original chassis description of the mech
var dict: Dictionary

signal clicked(selected_mech: Mech)
signal design_changed()
signal description_changed(new_description: String)

var move_speed: int = 0
var moved_this_turn: int = 0

# part dictionaries contain:
#   "type": "weapon" or "module"
#   "content": Weapon or Module (may be null)
#   "hangar_pos": location to display module slot in hangar
#   "battle_pos": only present for weapons, weapon fire location on top-down
var parts: Array[Dictionary]

var max_shield: int: set = set_max_shield
var max_armor: int: set = set_max_armor
var shield: int: set = set_shield
var armor: int: set = set_armor

var max_weight: int

var accuracy_bonus: float: set = set_accuracy_bonus

# Records whether the mech has ever been in the scene tree
var readied: bool = false


# mech dictionary contains
#   "battle_img": top-down display sprite
#   "hangar_img" (not used here)
#   "slots": array of dictionaries describing each slot
static func create_from_dict(mech_dict: Dictionary) -> Mech:
	var new_mech: Mech = pack_mech.instantiate()
	new_mech.dict = mech_dict
	new_mech.set_sprite(mech_dict["battle_img"])
	var slots: Array[Dictionary] = Array(mech_dict["slots"], TYPE_DICTIONARY, "", null)
	new_mech.create_part_slots(slots)
	new_mech.max_weight = mech_dict["max_weight"]
	return new_mech



# passed in dictionaries contain:
#   "type": the kind of part that can go there
#   "hangar_pos": location to display in hangar
#   "battle_pos": only present for weapons, weapon fire location on top-down

# dictionaries to be created should contain:
#   "type": the kind of part that can go there
#   "content": Weapon or Module (may be null)
#   "hangar_pos": location to display module slot in hangar
#   "battle_pos": only present for weapons, weapon fire location on top-down
func create_part_slots(slots: Array[Dictionary]) -> void:
	parts = []
	for slot: Dictionary in slots:
		var new_dict = slot.duplicate()
		new_dict["content"] = null
		parts.append(new_dict)


func get_dict() -> Dictionary:
	return dict

func _init() -> void:
	parts = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	readied = true
	max_armor = 100
	
	apply_modules()
	
	shield = max_shield
	armor = max_armor


func set_parameters(pos: Vector2, sprite_path: String) -> void:
	position = pos
	$Sprite.texture = load(sprite_path)

func set_sprite(sprite_path: String) -> void:
	$Sprite.texture = load(sprite_path)
	
	

func apply_modules() -> void:
	max_shield = 0
	accuracy_bonus = 0
	move_speed = 0
	for part: Dictionary in parts:
		if(part["type"] != "weapon" and part["content"] != null):
			apply_module(part["content"])
	

func apply_module(module: Module) -> void:
	move_speed += module.speed
	max_shield += module.shield
	accuracy_bonus = accuracy_bonus + module.accuracy

func get_max_weight() -> int:
	return max_weight

func get_used_weight() -> int:
	var used_weight: int = 0
	for part: Dictionary in parts:
		if( part["content"] != null ):
			used_weight += part["content"].weight
	return used_weight

func get_description() -> String:
	var ret_text: String = ""
	ret_text += "Chassis: " + dict["name"] + "\n\n"
	ret_text += "Move Speed: " + str(move_speed) + "\n"
	ret_text += "Shield: " + str(max_shield) + "\n"
	ret_text += "Accuracy Bonus: " + str(accuracy_bonus*100) + "%\n"
	ret_text += "Weight: " + str(get_used_weight()) + "/" + str(max_weight)
	
	
	
	return ret_text

func is_over_weight() -> bool:
	return get_used_weight() > max_weight

# Creates ModuleSlot objects, and passes an array of dictionaries that contain
#   "slot": the ModuleSlot object
#   "pos": the place in the hangar to display it
func get_slots_with_positions() -> Array[Dictionary]:
	var slots_arr: Array[Dictionary] = []
	for i in range(parts.size()):
		var slot_dict: Dictionary = parts[i]
		var slot: ModuleSlot = ModuleSlot.new()
		slot.set_type(slot_dict["type"])
		slot.contents_changed_to.connect(_on_slot_changed_to.bind(i))
		if( slot_dict["content"] != null ):
			if slot_dict["type"] == "weapon":
				slot.set_panel_from_weapon(slot_dict["content"])
			else:
				slot.set_panel_from_module(slot_dict["content"])
		
		slots_arr.append({
			"slot": slot,
			"pos": slot_dict["hangar_pos"]
		})
		
	return slots_arr


func _on_slot_changed_to(new_part: ModulePanel, index: int) -> void:
	if( new_part == null ):
		remove_part_at_slot(index)
	elif( new_part.type == "weapon" ):
		set_weapon_at_slot(index, new_part.weapon)
	else:
		set_module_at_slot(index, new_part.module)
	design_changed.emit()
	description_changed.emit(get_description())


func remove_part_at_slot(index: int) -> void:
	var part_dict: Dictionary = parts[index]
	part_dict["content"] = null

func set_module_at_slot(index: int, module: Module ) -> void:
	var module_dict: Dictionary = parts[index]
	if( module_dict["type"] == "weapon"):
		assert(false, "module passed into wrong part index")
		return
	module_dict["content"] = module
	apply_modules()
	pass
	
	
func set_weapon_at_slot(index: int, weapon: Weapon ) -> void:
	var weapon_dict: Dictionary = parts[index]
	if( weapon_dict["type"] != "weapon"):
		assert(false, "weapon passed into wrong part index")
		return
	var cur_weapon: Weapon = weapon_dict["content"]
	if( cur_weapon != null ):
		cur_weapon.queue_free()
		remove_child(cur_weapon)
	weapon_dict["content"] = weapon
	add_weapon(weapon)
	pass

func add_module(module: Module) -> void:
	var module_dict: Dictionary = {}
	module_dict["type"] = "module"
	module_dict["content"] = module
	parts.append(module_dict)
	

func add_weapon(new_weapon: Weapon) -> void:
	new_weapon.mech_accuracy = accuracy_bonus
	add_child(new_weapon)
	

func add_laser() -> void:
	var new_weapon: Weapon = Weapon.new()
	new_weapon.set_parameters("laser")
	new_weapon.position = Vector2(randi_range(-30, 30), randi_range(-30, 30))
	new_weapon.mech_accuracy = accuracy_bonus
	
	var weapon_dict: Dictionary = {}
	weapon_dict["type"] = "weapon"
	weapon_dict["content"] = new_weapon
	parts.append(weapon_dict)
	add_child(new_weapon)

func highlight() -> void:
	$Highlight.visible = true
	
func unhighlight() -> void:
	$Highlight.visible = false
	
func target(new_target: Mech) -> void:
	for part: Dictionary in parts:
		if(part["type"] == "weapon" and part["content"] != null):
			part["content"].change_target(new_target)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		make_input_local(event)
		var shape: Rect2 = $Collider.shape.get_rect()
		if shape.has_point(event.position-self.position):
			clicked.emit(self)
			get_viewport().set_input_as_handled()
			

func get_radius() -> float:
	# BAD MAGIC NUMBER
	return 60

func get_remaining_move() -> int:
	return max(move_speed - moved_this_turn, 0)
	
func get_fire_buttons() -> Array[Button]:
	var buttons: Array[Button] = []
	for part: Dictionary in parts:
		if(part["type"] == "weapon" and part["content"] != null):
			buttons.append(part["content"].get_fire_button())
	return buttons
	
func spend_move(spent: int) -> void:
	moved_this_turn += spent
	
func new_turn() -> void:
	moved_this_turn = 0
	for part: Dictionary in parts:
		if(part["type"] == "weapon" and part["content"] != null):
			part["content"].new_turn()

func has_shield() -> bool:
	return shield > 0

func apply_damage_shield(damage: int) -> void:
	shield = max(0, shield - damage)

func apply_damage_armor(damage: int) -> void:
	armor = max(0, armor - damage)
	$ArmorBar.value = armor
	
func set_max_shield(value: int) -> void:
	max_shield = value
	if(readied):
		if(max_shield == 0):
			$ShieldBar.visible = false
		else:
			$ShieldBar.visible = true
			$ShieldBar.max_value = max_shield
			$ShieldBar.size.x = float(max_shield)/(max_armor) * $ArmorBar.size.x
			$ShieldBar.position.x = -($ShieldBar.size.x / 2)


func set_max_armor(value: int) -> void:
	max_armor = value
	if(readied):
		$ArmorBar.max_value = max_armor
	
func set_shield(value: int) -> void:
	shield = value
	if(readied):
		$ShieldBar.value = shield
	
func set_armor(value: int) -> void:
	armor = value
	if(readied):
		$ArmorBar.value = armor
	
func set_accuracy_bonus(value: float) -> void:
	accuracy_bonus = value
	for part: Dictionary in parts:
		if(part["type"] == "weapon" and part["content"] != null):
			part["content"].mech_accuracy = accuracy_bonus
			
