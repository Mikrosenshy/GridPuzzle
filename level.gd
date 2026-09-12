class_name LevelManager
extends RefCounted

var current_level: int = 1

func get_grid_dimensions() -> Vector2i:
	if current_level >= 15 and randf() < 0.30:
		var reduced_w = randi_range(4, 5)
		var reduced_h = randi_range(4, 5)
		return Vector2i(reduced_w, reduced_h)

	var size = min(4 + (current_level - 1) / 3, Init.MAX_GRID_SIZE)
	return Vector2i(size, size)

func get_level_colors() -> Array[Color]:
	var active_count: int = 3
	if current_level >= 15 and randf() < 0.30:
		active_count = randi_range(3, 4)
	else:
		active_count = min(3 + (current_level - 1) / 4, Init.PALETTE.size())

	var level_colors: Array[Color] = []
	for i in range(active_count):
		level_colors.append(Init.PALETTE[i])

	return level_colors

func calculate_cell_size(viewport_size: Vector2, grid_dim: Vector2i) -> Vector2:
	var available_w = viewport_size.x * Init.SIDEBAR_RATIO
	var available_h = viewport_size.y

	var cell_w = available_w / float(grid_dim.x)
	var cell_h = available_h / float(grid_dim.y)

	var side = min(cell_w, cell_h)
	return Vector2(side, side)
