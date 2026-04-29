extends Node2D

var selected_mech: Mech = null

@onready var mech_packed: PackedScene = load("res://Battlefield/Mech/mech.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_mech: Mech = mech_packed.instantiate()
	
	var grid_loc: Vector2i = Vector2i(5, -2)
	new_mech.set_parameters($Terrain.map_to_local(grid_loc))
	new_mech.selected.connect(_on_mech_selected)
	
	add_child(new_mech)
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_mech_selected(selected: Mech) -> void:
	# unhighlight all mechs
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is Mech:
			child.unhighlight()
	
	selected.highlight()
	selected_mech = selected
	pass # Replace with function body.


func _on_terrain_click_at(grid_loc: Vector2i) -> void:
	if(selected_mech):
		selected_mech.position = $Terrain.map_to_local(grid_loc)
		selected_mech.unhighlight()
		selected_mech = null
