extends TileMapLayer

# Hex grid maths:
# We'll call down-right "q" and down-left "s", based on 
#       https://www.redblobgames.com/grids/hexagons/
# Distance is the greatest of (|q|, |s|, |q + s|)
# All hexes within range N must have loops that constrain all three things
# Loop through q, and then s = -N or s + q = -N so s = -N - q 
#                       to s = N or s + q = N, so s = N - q
#                       both constraints, so max on low side, min on high
 

func display_radius_at(loc: Vector2i, radius: int):
	if radius == 0:
		return
	for q in range(-radius, radius + 1): # top of range() is exclusive
		var low: int = max( -radius, -radius - q)
		var high: int = min( radius, radius - q)
		for s in range(low, high + 1):
			set_cell(Vector2i(q, s) + loc, 0, Vector2i(0, 0), 0)


func is_valid_move(loc: Vector2i) -> bool:
	return get_cell_source_id(loc) != -1
	
