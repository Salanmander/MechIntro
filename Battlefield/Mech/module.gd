extends Resource
class_name Module


var shield: int = 0
var speed: int = 0
var accuracy: float = 0

var weight: int = 0


# module dictionary contains:
#   "type", "name" (not used here)
#   "effects": array of dictionaries, each with
#     "type": "shield", "speed", or "accuracy"
#     "val": the amount granted of the given effect
#   "weight": weight of the module
static func create_from_dict(mod: Dictionary) -> Module:
	var new_mod: Module = Module.new()
	new_mod.weight = mod["weight"]
	
	for effect: Dictionary in mod["effects"]:
		if( effect["type"] == "shield" ):
			new_mod.shield += effect["val"]
		if( effect["type"] == "speed" ):
			new_mod.speed += effect["val"]
		if( effect["type"] == "accuracy" ):
			new_mod.accuracy += effect["val"]
			
	return new_mod
	
	

static func create_shield(shield: int, weight: int) -> Module:
	var new_mod: Module = Module.new()
	new_mod.shield = shield
	new_mod.weight = weight
	return new_mod
	
	
static func create_speed(speed: int, weight: int) -> Module:
	var new_mod: Module = Module.new()
	new_mod.speed = speed
	new_mod.weight = weight
	return new_mod

	
static func create_accuracy(accuracy: float, weight: int) -> Module:
	var new_mod: Module = Module.new()
	new_mod.accuracy = accuracy
	new_mod.weight = weight
	return new_mod
	
func get_effects_array() -> Array[Dictionary]:
	var effects: Array[Dictionary] = []
	if( shield != 0 ):
		effects.append({"type": "shield", "val": shield})
	if( speed != 0 ):
		effects.append({"type": "speed", "val": shield})
	if( accuracy != 0 ):
		effects.append({"type": "accuracy", "val": accuracy})
	return effects
