extends Node



# Only to be called form the hangar
func start_battlefield() -> void:
	var hangar: Node = get_tree().current_scene
	var team1: Array[Mech] = hangar.team1
	var team2: Array[Mech] = hangar.team2
	get_tree().root.remove_child(hangar)
	hangar.queue_free()
	
	var battlefield = load("res://Battlefield/battlefield.tscn").instantiate()
	get_tree().root.add_child(battlefield)
	battlefield.add_team(1, team1)
	battlefield.add_team(2, team2)
	get_tree().current_scene = battlefield
	
	
	
