extends Node2D
class_name Weapon


var fire_button: Button = null
var target: Mech = null

var accuracy: float = 0.75
var mech_accuracy: float = 0

var dam_shield: int = 20
var dam_armor: int = 10

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
	return new_weap

func set_parameters(name: String) -> void:
	fire_button = Button.new()
	fire_button.text = "name"
	fire_button.button_down.connect(fire)

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
	if(randf() > accuracy + mech_accuracy):
		draw_laser_hit(false)
		return
	draw_laser_hit(true)
	if(target.has_shield()):
		target.apply_damage_shield(dam_shield)
	else:
		target.apply_damage_armor(dam_armor)
	pass
	

func draw_laser_hit(hit: bool) -> void:
	var dist: float = (target.position - global_position).length()
	var max_ratio: float = target.get_radius() / dist
	var max_angle: float = atan(max_ratio)
	
	var angle: float
	var length: float
	if(hit):
		angle = randf_range(-max_angle, max_angle)
		length = dist
	else:
		angle = randf_range(max_angle, 2*max_angle)
		if( randf() > 0.5 ):
			angle *= -1
		length = dist*2
	
	angle += global_position.angle_to_point(target.position)
	
	var laser: Line2D = Line2D.new()
	laser.width = 2
	laser.add_point(position)
	laser.add_point(Vector2(length * cos(angle), length * sin(angle)))
	add_child(laser)
	
	get_tree().create_timer(0.3).timeout.connect(laser.queue_free)
	pass


func change_target(new_target: Mech) -> void:
	target = new_target

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
