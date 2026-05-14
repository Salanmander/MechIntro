extends Node2D
class_name Weapon


signal shot_fired(shot: CannonShot)
signal laser_fired(laser: Line2D)

var fire_button: Button = null
var target: Mech = null

var accuracy: float = 0.75
var mech_accuracy: float = 0

var dam_shield: int = 20
var dam_armor: int = 10

# spread is stored in degrees
var spread: float = 0
var weight: int = 0

var weapon_type: String = ""
var weapon_name: String = ""

# weapon dictionary contains:
#   "type" (not used here)
#   "weapon_type" (ignored for now, but recorded)
#   "name": display name 
#   "shield_dam"
#   "armor_dam"
#   "weight" 
#   "spread": angular spread of weapon in radians
static func create_from_dict(weap: Dictionary) -> Weapon:
	var new_weap: Weapon = Weapon.new()
	new_weap.dam_shield = weap["shield_dam"]
	new_weap.dam_armor = weap["armor_dam"]
	new_weap.spread = weap["spread"]
	new_weap.weight = weap["weight"]
	new_weap.weapon_type = weap["weapon_type"]
	new_weap.weapon_name = weap["name"]
	new_weap.setup_button()
	return new_weap

func setup_button() -> void:
	fire_button = Button.new()
	update_fire_button_text()
	fire_button.button_down.connect(fire)
	
func update_fire_button_text():
	var button_text: String = weapon_name + "\n"
	if( target ):
		var hit_prob: float = get_hit_prob()
		hit_prob *= 100
		button_text += str(int(hit_prob)) + "%"
	else:
		var spread_angle: float = spread * (1-mech_accuracy)
		button_text += "spread: " + "%.1f"%spread_angle + "°"
	
	fire_button.text = button_text
		
	pass

func get_fire_button() -> Button:
	return fire_button

func disable() -> void:
	fire_button.disabled = true
	
func enable() -> void:
	fire_button.disabled = false

func new_turn() -> void:
	enable()

func fire() -> void:
	if(not target):
		return
	disable()
	var hit: bool = draw_weapon_and_hit()
	if( not hit ):
		return
	if(target.has_shield()):
		target.apply_damage_shield(dam_shield)
	else:
		target.apply_damage_armor(dam_armor)
	pass
	

func draw_weapon_and_hit() -> bool:
	var dist: float = (target.position - global_position).length()
	var max_ratio: float = target.get_radius() / dist
	var max_angle: float = atan(max_ratio)
	
	var angle_spread: float = max(0, deg_to_rad(spread) * (1 - mech_accuracy))
	
	var angle: float = randf_range(-angle_spread, angle_spread)
	var hit: bool = abs(angle) <= abs(max_angle)
	var length: float
	if(hit):
		length = dist
	else:
		# bad magic number!
		# Enough pixels to reliably go off the screen
		length = 5000
	
	angle += global_position.angle_to_point(target.position)
	draw_weapon(Vector2(length * cos(angle), length * sin(angle)))
	
	return hit
	

func draw_weapon(target: Vector2) -> void:
	if(weapon_type == "laser"):
		
		var laser: Line2D = Line2D.new()
		laser.width = 2
		laser.add_point(global_position)
		laser.add_point(global_position + target)
		get_tree().create_timer(0.3).timeout.connect(laser.queue_free)

		laser_fired.emit(laser)
		
	elif(weapon_type == "cannon"):
		var shot: CannonShot = CannonShot.create(target)
		shot.position = global_position
		shot.target = global_position + target
		shot_fired.emit(shot)
		pass

func get_hit_prob() -> float:
	if(not target):
		return -1
	var dist: float = (target.position - global_position).length()
	var max_ratio: float = target.get_radius() / dist
	var max_angle: float = atan(max_ratio)
	
	var angle_spread: float = max(0, deg_to_rad(spread) * (1 - mech_accuracy))
	
	return min( 1, max_angle/angle_spread )


func change_target(new_target: Mech) -> void:
	target = new_target
	update_fire_button_text()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
