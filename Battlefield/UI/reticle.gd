extends Node2D
class_name Reticle

# speed of rotation in radians per second
const angle_speed: float = -0.8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	rotation += angle_speed * delta
	rotation = fmod(rotation, 360)
	pass
