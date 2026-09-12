class_name Enemy
extends RefCounted

var pos: Vector2i
var color_idx: int
var is_alive: bool = true
var flee_chance: float = 0.08
var texture: Texture2D

func _init(start_pos: Vector2i, forbidden_color_idx: int, evasion_rate: float = 0.08) -> void:
	pos = start_pos
	color_idx = forbidden_color_idx
	flee_chance = evasion_rate

# Färbt exakt den äußeren 1-Pixel-Rand des Sprites in der verbotenen Farbe ein
func update_texture(forbidden_color: Color) -> void:
	var original_img: Image = Init.tex_enemy.get_image().duplicate()
	var img: Image = original_img.duplicate()
	var w: int = img.get_width()
	var h: int = img.get_height()

	for x in range(w):
		for y in range(h):
			if original_img.get_pixel(x, y).a > 0.1:
				var is_border: bool = false
				
				# Prüft im Radius von 1 Pixel auf Bildränder oder Transparenz
				for dx in range(-1, 2):
					for dy in range(-1, 2):
						if dx == 0 and dy == 0:
							continue
						var nx: int = x + dx
						var ny: int = y + dy
						
						if nx < 0 or nx >= w or ny < 0 or ny >= h:
							is_border = true
							break
						elif original_img.get_pixel(nx, ny).a <= 0.1:
							is_border = true
							break
					if is_border:
						break
				
				if is_border:
					img.set_pixel(x, y, forbidden_color)

	texture = ImageTexture.create_from_image(img)

func make_move(player_pos: Vector2i, grid_data: Array, grid_width: int, grid_height: int) -> void:
	if not is_alive:
		return

	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var valid_moves: Array[Vector2i] = []

	for dir in directions:
		var target = pos + dir
		if target.x >= 0 and target.x < grid_width and target.y >= 0 and target.y < grid_height:
			if grid_data[target.x][target.y] != color_idx:
				valid_moves.append(target)

	if valid_moves.size() == 0:
		return

	var current_dist = abs(pos.x - player_pos.x) + abs(pos.y - player_pos.y)
	var is_directly_adjacent = (current_dist == 1)

	var adjacent_moves: Array[Vector2i] = []
	for target in valid_moves:
		if abs(target.x - player_pos.x) + abs(target.y - player_pos.y) == 1:
			adjacent_moves.append(target)

	var active_flee_chance = flee_chance
	if is_directly_adjacent:
		active_flee_chance = min(1.0, flee_chance * 2.0)

	if is_directly_adjacent or adjacent_moves.size() > 0:
		if randf() < active_flee_chance:
			var furthest_move = pos
			var max_dist = -1.0
			for target in valid_moves:
				var dist = target.distance_squared_to(player_pos)
				if dist > max_dist:
					max_dist = dist
					furthest_move = target
			pos = furthest_move
			return

	var best_move = pos
	var min_distance = 999999.0

	for target in valid_moves:
		var dist = target.distance_squared_to(player_pos)
		if dist < min_distance:
			min_distance = dist
			best_move = target

	pos = best_move

func make_timed_move(player_pos: Vector2i, grid_data: Array, grid_width: int, grid_height: int) -> void:
	if not is_alive:
		return

	var directions = [Vector2i(1, 0), Vector2i(-1, 0), Vector2i(0, 1), Vector2i(0, -1)]
	var valid_moves: Array[Vector2i] = []

	for dir in directions:
		var target = pos + dir
		if target.x >= 0 and target.x < grid_width and target.y >= 0 and target.y < grid_height:
			if grid_data[target.x][target.y] != color_idx and target != player_pos:
				valid_moves.append(target)

	if valid_moves.size() == 0:
		return

	var best_move = pos
	var min_distance = 999999.0

	for target in valid_moves:
		var dist = target.distance_squared_to(player_pos)
		if dist < min_distance:
			min_distance = dist
			best_move = target

	pos = best_move
