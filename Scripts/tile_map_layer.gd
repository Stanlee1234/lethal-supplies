extends TileMapLayer # Use TileMap if you're on Godot 3 / early 4

# Atlas coordinates based on your 6 vertical rows
const ATLAS_GREY_LEFT   = Vector2i(0, 0)
const ATLAS_GREY_RIGHT  = Vector2i(0, 1)
const ATLAS_BLUE_LEFT   = Vector2i(0, 2)
const ATLAS_BLUE_RIGHT  = Vector2i(0, 3)
const ATLAS_GREY_MIDDLE = Vector2i(0, 4)
const ATLAS_BLUE_MIDDLE = Vector2i(0, 5)

var bar_start_cell: Vector2i
var bar_length: int = 0

# Charge states: 0.0 = fully empty (grey), 1.0 = fully charged (ready to dash)
var current_charge: float = 0.0
var recharge_speed: float = 0.1 # Takes 2 seconds to recharge from 0 to 1

func _ready() -> void:
	# Automatically detect the bar you already placed in the editor
	var used_cells = get_used_cells()
	if used_cells.is_empty():
		return
	
	# Sort cells from left to right
	used_cells.sort_custom(func(a, b): return a.x < b.x)
	bar_start_cell = used_cells[0]
	bar_length = used_cells.size()
	
	# Start fully charged (or 0.0 if you want it to charge up on spawn)
	current_charge = 1.0
	update_bar()

func _process(delta: float) -> void:
	if current_charge < 1.0:
		current_charge = min(current_charge + recharge_speed * delta, 1.0)
		update_bar()

func update_bar() -> void:
	if bar_length == 0:
		return

	# Number of tiles that should display blue
	var charged_count = int(current_charge * bar_length)

	for i in range(bar_length):
		var cell_pos = bar_start_cell + Vector2i(i, 0)
		var is_charged = (i < charged_count)
		var atlas_coords: Vector2i

		if i == 0:
			atlas_coords = ATLAS_BLUE_LEFT if is_charged else ATLAS_GREY_LEFT
		elif i == bar_length - 1:
			atlas_coords = ATLAS_BLUE_RIGHT if is_charged else ATLAS_GREY_RIGHT
		else:
			atlas_coords = ATLAS_BLUE_MIDDLE if is_charged else ATLAS_GREY_MIDDLE

		set_cell(cell_pos, 0, atlas_coords)

# Call this function from your player script when dashing
func use_dash() -> bool:
	if current_charge >= 1.0:
		current_charge = 0.0
		update_bar()
		return true 
	return false # Dash on cooldown
