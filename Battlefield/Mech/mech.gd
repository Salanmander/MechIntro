extends Area2D
class_name Mech

static var pack_mech: PackedScene = load("res://Battlefield/Mech/mech.tscn")

# Holds the original chassis description of the mech
var dict: Dictionary

signal clicked(selected_mech: Mech)

var move_speed: int = 0
var moved_this_turn: int = 0

var weapons: Array[Weapon]
var modules: Array[Module]

var max_shield: int: set = set_max_shield
var max_armor: int: set = set_max_armor
var shield: int: set = set_shield
var armor: int: set = set_armor

var accuracy_bonus: float: set = set_accuracy_bonus

static func create_from_dict(mech_dict: Dictionary) -> Mech:
	var new_mech: Mech = pack_mech.instantiate()
	new_mech.dict = mech_dict
	new_mech.set_parameters(Vector2(0, 0), mech_dict["battle_img"])
	return new_mech


func _init() -> void:
	
	weapons = []
	
	add_laser()
	add_laser()
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	max_armor = 100
	
	apply_modules()
	
	shield = max_shield
	armor = max_armor


func set_parameters(pos: Vector2, sprite_path: String) -> void:
	position = pos
	$Sprite.texture = load(sprite_path)


func apply_modules() -> void:
	max_shield = 0
	accuracy_bonus = 0
	move_speed = 0
	for module: Module in modules:
		apply_module(module)
	
	

func apply_module(module: Module) -> void:
	move_speed += module.speed
	max_shield += module.shield
	accuracy_bonus = accuracy_bonus + module.accuracy

func add_module(module: Module) -> void:
	modules.append(module)
	

func add_laser() -> void:
	var new_weapon: Weapon = Weapon.new()
	new_weapon.position = Vector2(randi_range(-30, 30), randi_range(-30, 30))
	new_weapon.mech_accuracy = accuracy_bonus
	weapons.append(new_weapon)
	add_child(new_weapon)

func highlight() -> void:
	$Highlight.visible = true
	
func unhighlight() -> void:
	$Highlight.visible = false
	
func target(new_target: Mech) -> void:
	for weapon: Weapon in weapons:
		weapon.change_target(new_target)

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
	for weapon: Weapon in weapons:
		buttons.append(weapon.get_fire_button())
	return buttons
	
func spend_move(spent: int) -> void:
	moved_this_turn += spent
	
func new_turn() -> void:
	moved_this_turn = 0
	for weapon: Weapon in weapons:
		weapon.new_turn()

func has_shield() -> bool:
	return shield > 0

func apply_damage_shield(damage: int) -> void:
	shield = max(0, shield - damage)

func apply_damage_armor(damage: int) -> void:
	armor = max(0, armor - damage)
	$ArmorBar.value = armor
	
func set_max_shield(value: int) -> void:
	max_shield = value
	if(max_shield == 0):
		$ShieldBar.visible = false
	else:
		$ShieldBar.visible = true
		$ShieldBar.max_value = max_shield
		$ShieldBar.size.x = float(max_shield)/(max_armor) * $ArmorBar.size.x
		$ShieldBar.position.x = -($ShieldBar.size.x / 2)


func set_max_armor(value: int) -> void:
	max_armor = value
	$ArmorBar.max_value = max_armor
	
func set_shield(value: int) -> void:
	shield = value
	$ShieldBar.value = shield
	
func set_armor(value: int) -> void:
	armor = value
	$ArmorBar.value = armor
	
func set_accuracy_bonus(value: float) -> void:
	accuracy_bonus = value
	for weapon: Weapon in weapons:
		weapon.mech_accuracy = accuracy_bonus
