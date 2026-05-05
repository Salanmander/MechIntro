extends Resource
class_name Module


var shield: int
var speed: int
var accuracy: float

var weight: int


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
