extends Area2D
class_name Mech

signal selected(selected_mech: Mech)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_parameters(pos: Vector2) -> void:
	position = pos

func highlight() -> void:
	$Highlight.visible = true
	
func unhighlight() -> void:
	$Highlight.visible = false

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.is_pressed():
		make_input_local(event)
		var shape: Rect2 = $Collider.shape.get_rect()
		if shape.has_point(event.position-self.position):
			selected.emit(self)
			get_viewport().set_input_as_handled()
			
	

	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
	
