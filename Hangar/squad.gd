extends Panel

signal slot_selected(slot: MechSlot)
signal squad_over_weight(is_over_weight: bool)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(3):
		var new_slot: MechSlot = MechSlot.new()
		new_slot.mech_made_over_weight.connect(_on_mech_overweight_change)
		new_slot.selected.connect(_on_slot_selected.bind(new_slot))
		$MechContainer.add_child(new_slot)
		

func _on_slot_selected(slot: MechSlot) -> void:
	slot_selected.emit(slot)
	for child: Node in $MechContainer.get_children():
		if child is MechSlot:
			child.set_inactive()


func get_squad() -> Array[Mech]:
	var squad: Array[Mech] = []
	for child: Node in $MechContainer.get_children():
		if child is MechSlot:
			var mech: Mech = child.get_held_mech()
			if( mech ):
				squad.append(mech)
	return squad
	
func _on_mech_overweight_change(is_now_over_weight: bool) -> void:
	if( is_now_over_weight ):
		squad_over_weight.emit(true)
	else:
		var over_weight = false
		for child: Node in $MechContainer.get_children():
			if child is MechSlot:
				if child.mech_over_weight:
					over_weight = true
		squad_over_weight.emit(over_weight)
	pass
