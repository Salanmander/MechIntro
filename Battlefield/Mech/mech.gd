extends Area2D
class_name Mech

signal clicked(selected_mech: Mech)

var move_speed: int
var moved_this_turn: int

var weapons: Array[Weapon]

var max_shield: int
var max_armor: int
var shield: int
var armor: int

func _init() -> void:
	max_shield = 50
	max_armor = 100
	shield = max_shield
	armor = max_armor
	

	weapons = []
	
	add_laser()
	add_laser()
	
	move_speed = 4
	moved_this_turn = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	$ShieldBar.max_value = max_shield
	$ShieldBar.value = shield
	$ArmorBar.max_value = max_armor
	$ArmorBar.value = armor
	pass # Replace with function body.

func set_parameters(pos: Vector2, sprite_path: String) -> void:
	position = pos
	$Sprite.texture = load(sprite_path)


func add_laser() -> void:
	var new_weapon: Weapon = Weapon.new()
	new_weapon.position = Vector2(randi_range(-30, 30), randi_range(-30, 30))
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
	$ShieldBar.value = shield

func apply_damage_armor(damage: int) -> void:
	armor = max(0, armor - damage)
	$ArmorBar.value = armor
	
