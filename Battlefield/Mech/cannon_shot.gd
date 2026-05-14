extends Sprite2D
class_name CannonShot

var target: Vector2

signal exploded(pos: Vector2)

# Velocity in pixels per second
var v: float = 4000

static var shot_text = load("res://Battlefield/Mech/cannonShot.png")

static func create(target: Vector2) -> CannonShot:
	var new_shot: CannonShot = CannonShot.new()
	new_shot.target = target
	return new_shot

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	texture = shot_text


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var dir: Vector2 = position.direction_to(target)
	if( position.distance_to(target) > (v*delta) ):
		position += dir * (v * delta)
	else:
		queue_free()
		exploded.emit(target)
	pass
