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
	
	var grid_loc: Vector2i = $Terrain.local_to_map(selected.position)
	$MoveOverlay.clear()
	$MoveOverlay.display_radius_at(grid_loc, selected.get_remaining_move())
	pass # Replace with function body.


func _on_terrain_click_at(grid_loc: Vector2i) -> void:
	if(selected_mech):
		if($MoveOverlay.is_valid_move(grid_loc)):
			var mech_loc: Vector2i = $Terrain.local_to_map(selected_mech.position)
			var move_tiles: Vector2i = grid_loc - mech_loc
			var q = move_tiles.x
			var s = move_tiles.y
			var move_dist: int = max(abs(q), abs(s), abs(q + s))
			
			selected_mech.spend_move(move_dist)
			selected_mech.position = $Terrain.map_to_local(grid_loc)
		
		$MoveOverlay.clear()
		selected_mech.unhighlight()
		selected_mech = null


func _on_end_turn_pressed() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is Mech:
			child.new_turn()
	pass # Replace with function body.
