extends Node2D



var selected_mech: Mech = null
var friendly_mechs: Array[Mech] = []
var enemy_mechs: Array[Mech] = []

@onready var pack_mech: PackedScene = load("res://Battlefield/Mech/mech.tscn")
@onready var pack_reticle: PackedScene = load("res://Battlefield/UI/reticle.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var new_mech: Mech = pack_mech.instantiate()
	
	var friendly_sprite: String = "res://Battlefield/Mech/mech.png"
	var enemy_sprite: String = "res://Battlefield/Mech/enemy.png"
	
	var grid_loc: Vector2i = Vector2i(5, 3)
	new_mech.set_parameters($Terrain.map_to_local(grid_loc), friendly_sprite)
	new_mech.clicked.connect(_on_mech_clicked)
	new_mech.add_laser()
	add_child(new_mech)
	friendly_mechs.append(new_mech)
	
	new_mech = pack_mech.instantiate()
	grid_loc = Vector2i(10, -6)
	new_mech.set_parameters($Terrain.map_to_local(grid_loc), friendly_sprite)
	new_mech.clicked.connect(_on_mech_clicked)
	add_child(new_mech)
	friendly_mechs.append(new_mech)
	
	
	new_mech = pack_mech.instantiate()
	grid_loc = Vector2i(8, -7)
	new_mech.set_parameters($Terrain.map_to_local(grid_loc), enemy_sprite)
	new_mech.clicked.connect(_on_mech_clicked)
	add_child(new_mech)
	enemy_mechs.append(new_mech)
	
	
	new_mech = pack_mech.instantiate()
	grid_loc = Vector2i(9, -8)
	new_mech.set_parameters($Terrain.map_to_local(grid_loc), enemy_sprite)
	new_mech.clicked.connect(_on_mech_clicked)
	add_child(new_mech)
	enemy_mechs.append(new_mech)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _on_mech_clicked(selected: Mech) -> void:
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
		untarget_all()
		selected_mech.unhighlight()
		selected_mech = null
		var current_buttons: Array[Node] = $Controls/Weapons.get_children()
		for button: Node in current_buttons:
			$Controls/Weapons.remove_child(button)


func _on_end_turn_pressed() -> void:
	var children: Array[Node] = get_children()
	for child: Node in children:
		if child is Mech:
			child.new_turn()
	pass # Replace with function body.
