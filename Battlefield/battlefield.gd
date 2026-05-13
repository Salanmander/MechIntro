extends Node2D



var selected_mech: Mech = null

var active_team: int = 1

var team1_mechs: Array[Mech] = []
var team2_mechs: Array[Mech] = []

@onready var pack_mech: PackedScene = load("res://Battlefield/Mech/mech.tscn")
@onready var pack_reticle: PackedScene = load("res://Battlefield/UI/reticle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_mech: Mech = pack_mech.instantiate()
	
	var friendly_sprite: String = "res://Battlefield/Mech/mech.png"
	var enemy_sprite: String = "res://Battlefield/Mech/enemy.png"
	
	
	pass # Replace with function body.

func add_team(team_num: int, squad: Array[Mech]) -> void:
	var grid_locs: Array[Vector2i]
	if( team_num == 1 ):
		grid_locs = [
			Vector2i(4, 2),
			Vector2i(6, 2),
			Vector2i(5, 0),
			]
	else:
		grid_locs = [
			Vector2i(8, -6),
			Vector2i(10, -6),
			Vector2i(10, -8),
			]
			
	for i in range (squad.size()):
		var grid_loc: Vector2i = grid_locs[i]
		var new_mech: Mech = squad[i]
		new_mech.position = $Terrain.map_to_local(grid_loc)
		new_mech.clicked.connect(_on_mech_clicked)
		add_child(new_mech)
		if( team_num == 1):
			team1_mechs.append(new_mech)
		else:
			team2_mechs.append(new_mech)
		

	

func _on_mech_clicked(selected: Mech) -> void:
	var friendly_mechs: Array[Mech]
	var enemy_mechs: Array[Mech]
	if( active_team == 1 ):
		friendly_mechs = team1_mechs
		enemy_mechs = team2_mechs
	else:
		friendly_mechs = team2_mechs
		enemy_mechs = team1_mechs
	if( selected in friendly_mechs ):
		select_mech(selected)
	elif( selected in enemy_mechs ):
		target_mech(selected)
	pass


func select_mech(selected: Mech) -> void:
	# unhighlight all mechs
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is Mech:
			child.unhighlight()
			
	
	selected.highlight()
	selected_mech = selected
	
	var current_buttons: Array[Node] = $Controls/Weapons.get_children()
	for button: Node in current_buttons:
		$Controls/Weapons.remove_child(button)
	var fire_buttons: Array[Button] = selected.get_fire_buttons()
	for button: Button in fire_buttons:
		$Controls/Weapons.add_child(button)
	
	var grid_loc: Vector2i = $Terrain.local_to_map(selected.position)
	$MoveOverlay.clear()
	$MoveOverlay.display_radius_at(grid_loc, selected.get_remaining_move())
	
	untarget_all()

func target_mech(new_target: Mech) -> void:
	if(selected_mech):
		untarget_all()
		selected_mech.target(new_target)
		var reticle: Reticle = pack_reticle.instantiate()
		reticle.position = new_target.position
		add_child(reticle)
	pass

func untarget_all() -> void:
	if(selected_mech):
		selected_mech.target(null)
	
	for child: Node in get_children():
		if child is Reticle:
			child.queue_free()
			remove_child(child)


func unselect_all() -> void:
	
	$MoveOverlay.clear()
	untarget_all()
	var current_buttons: Array[Node] = $Controls/Weapons.get_children()
	for button: Node in current_buttons:
		$Controls/Weapons.remove_child(button)
	
	if( selected_mech ):
		selected_mech.unhighlight()
		selected_mech = null

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
		
		unselect_all()
		


func _on_end_turn_pressed() -> void:
	unselect_all()
	var children: Array[Node] = get_children()
	active_team = active_team % 2 + 1
	for child: Node in children:
		if child is Mech:
			child.new_turn()
	pass # Replace with function body.
