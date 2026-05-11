extends Panel

signal slot_selected(slot: MechSlot)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	for i in range(3):
		var new_slot: MechSlot = MechSlot.new()
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
