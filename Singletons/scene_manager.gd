extends Node



# Only to be called form the hangar
func start_battlefield() -> void:
	var hangar: Node = get_tree().current_scene
	var squad: Array[Mech] = hangar.get_squad()
	get_tree().root.remove_child(hangar)
	hangar.queue_free()
	
	var battlefield = load("res://Battlefield/battlefield.tscn").instantiate()
	get_tree().root.add_child(battlefield)
	battlefield.add_squad(squad)
	get_tree().current_scene = battlefield
	
	
	
