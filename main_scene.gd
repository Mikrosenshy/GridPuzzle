extends Node2D

var lvl_mgr: LevelManager
var logic: GameLogic
var idle_timer: IdleTimer
var tutorial: Tutorial
var grid_width: int
var grid_height: int
var lvl_colors: Array[Color]

var grid_data: Array = []
var player: Player
var enemy: Enemy

func _ready() -> void:
	lvl_mgr = LevelManager.new()
	logic = GameLogic.new()
	idle_timer = IdleTimer.new()
	idle_timer.set_difficulty(logic.current_diff_idx)
	tutorial = Tutorial.new()
	player = Player.new(Vector2i(0, 0))
	
	get_viewport().size_changed.connect(func(): queue_redraw())
	start_level()

func _process(delta: float) -> void:
	if logic.state == GameLogic.State.PLAYING and enemy and enemy.is_alive:
		if not tutorial.is_active or tutorial.is_timer_active():
			if idle_timer.update(delta):
				enemy.make_timed_move(player.pos, grid_data, grid_width, grid_height)
				queue_redraw()

func start_level() -> void:
	lvl_colors = lvl_mgr.get_level_colors()
	var grid_dim = lvl_mgr.get_grid_dimensions()
	grid_width = grid_dim.x
	grid_height = grid_dim.y
	
	idle_timer.reset()
	generate_grid()

	if lvl_mgr.current_level == 1 and not tutorial.has_been_completed:
		tutorial.start_tutorial(self)
	else:
		tutorial.is_active = false
		tutorial.current_step = Tutorial.Step.FINISHED

func setup_tutorial_start() -> void:
	player.pos = Vector2i(0, 0)
	queue_redraw()

func generate_grid() -> void:
	var player_quad = randi() % 4
	var enemy_quad = (player_quad + 1 + (randi() % 3)) % 4

	player.pos = get_random_pos_in_quadrant(player_quad, grid_width, grid_height)
	var enemy_spawn = get_random_pos_in_quadrant(enemy_quad, grid_width, grid_height)

	grid_data.clear()
	for x in range(grid_width):
		var column: Array = []
		for y in range(grid_height):
			var random_color_idx = randi() % lvl_colors.size()
			column.append(random_color_idx)
		grid_data.append(column)

	var random_enemy_color_idx = randi() % lvl_colors.size()
	enemy = Enemy.new(enemy_spawn, random_enemy_color_idx, logic.get_current_flee_chance())
	enemy.update_texture(lvl_colors[enemy.color_idx])

	if grid_data[enemy.pos.x][enemy.pos.y] == enemy.color_idx:
		grid_data[enemy.pos.x][enemy.pos.y] = (enemy.color_idx + 1) % lvl_colors.size()

	var neighbors = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]
	for offset in neighbors:
		var n_pos = enemy.pos + offset
		if n_pos.x >= 0 and n_pos.x < grid_width and n_pos.y >= 0 and n_pos.y < grid_height:
			if grid_data[n_pos.x][n_pos.y] == enemy.color_idx:
				grid_data[n_pos.x][n_pos.y] = (enemy.color_idx + 1) % lvl_colors.size()

	var total_cells = grid_width * grid_height
	var min_required = max(max(grid_width, grid_height), int(total_cells * 0.20))
	var current_count = 0

	for x in range(grid_width):
		for y in range(grid_height):
			if grid_data[x][y] == enemy.color_idx:
				current_count += 1

	while current_count < min_required:
		var rx = randi() % grid_width
		var ry = randi() % grid_height
		var cell_pos = Vector2i(rx, ry)
		
		var is_neighbor = false
		for offset in neighbors:
			if cell_pos == enemy.pos + offset:
				is_neighbor = true
				break

		if cell_pos != player.pos and cell_pos != enemy.pos and not is_neighbor:
			if grid_data[rx][ry] != enemy.color_idx:
				grid_data[rx][ry] = enemy.color_idx
				current_count += 1

	queue_redraw()

func setup_tutorial_enemy_spawn() -> void:
	player.pos = Vector2i(0, 0)
	var enemy_spawn = Vector2i(grid_width - 1, grid_height - 1)
	
	var random_enemy_color_idx = randi() % lvl_colors.size()
	enemy = Enemy.new(enemy_spawn, random_enemy_color_idx, logic.get_current_flee_chance())
	enemy.update_texture(lvl_colors[enemy.color_idx])

	if grid_data[enemy.pos.x][enemy.pos.y] == enemy.color_idx:
		grid_data[enemy.pos.x][enemy.pos.y] = (enemy.color_idx + 1) % lvl_colors.size()

	var neighbors = [Vector2i(0, -1), Vector2i(-1, 0), Vector2i(1, 0), Vector2i(0, 1)]
	for offset in neighbors:
		var n_pos = enemy.pos + offset
		if n_pos.x >= 0 and n_pos.x < grid_width and n_pos.y >= 0 and n_pos.y < grid_height:
			if grid_data[n_pos.x][n_pos.y] == enemy.color_idx:
				grid_data[n_pos.x][n_pos.y] = (enemy.color_idx + 1) % lvl_colors.size()

	var total_cells = grid_width * grid_height
	var min_required = max(max(grid_width, grid_height), int(total_cells * 0.20))
	var current_count = 0

	for x in range(grid_width):
		for y in range(grid_height):
			if grid_data[x][y] == enemy.color_idx:
				current_count += 1

	while current_count < min_required:
		var rx = randi() % grid_width
		var ry = randi() % grid_height
		var cell_pos = Vector2i(rx, ry)
		
		var is_neighbor = false
		for offset in neighbors:
			if cell_pos == enemy.pos + offset:
				is_neighbor = true
				break

		if cell_pos != player.pos and cell_pos != enemy.pos and not is_neighbor:
			if grid_data[rx][ry] != enemy.color_idx:
				grid_data[rx][ry] = enemy.color_idx
				current_count += 1

	queue_redraw()

func get_random_pos_in_quadrant(quad_idx: int, width: int, height: int) -> Vector2i:
	var half_w = max(1, width / 2)
	var half_h = max(1, height / 2)
	
	var x_min = 0
	var x_max = half_w - 1
	var y_min = 0
	var y_max = half_h - 1
	
	if quad_idx == 1 or quad_idx == 3:
		x_min = half_w
		x_max = width - 1
	if quad_idx == 2 or quad_idx == 3:
		y_min = half_h
		y_max = height - 1
		
	return Vector2i(randi_range(x_min, x_max), randi_range(y_min, y_max))

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var viewport_size = get_viewport_rect().size
		
		var help_btn_x = viewport_size.x - 50.0
		var help_btn_y = 15.0
		var help_btn_rect = Rect2(Vector2(help_btn_x, help_btn_y), Vector2(35, 35))
		if help_btn_rect.has_point(event.position):
			tutorial.start_tutorial(self)
			queue_redraw()
			return

		var sidebar_x = viewport_size.x * Init.SIDEBAR_RATIO
		var btn_w = viewport_size.x * 0.16
		var btn_h = 45.0
		var btn_x = sidebar_x + (viewport_size.x * (1.0 - Init.SIDEBAR_RATIO) - btn_w) / 2.0
		var btn_y = viewport_size.y - 70.0
		var button_rect = Rect2(Vector2(btn_x, btn_y), Vector2(btn_w, btn_h))

		if button_rect.has_point(event.position):
			var new_flee_chance = logic.cycle_difficulty()
			idle_timer.set_difficulty(logic.current_diff_idx)
			if enemy:
				enemy.flee_chance = new_flee_chance
			queue_redraw()
			return

	if not (event is InputEventKey) or not event.pressed or event.echo:
		return

	if tutorial.is_active:
		var key = event.keycode if event.keycode != 0 else event.physical_keycode

		if key == KEY_ESCAPE:
			tutorial.cancel_tutorial()
			queue_redraw()
			return

		match tutorial.current_step:
			Tutorial.Step.MARK_PLAYER, Tutorial.Step.INTRO_ENEMY, Tutorial.Step.ENEMY_RULE_1, Tutorial.Step.ENEMY_RULE_2, Tutorial.Step.IDLE_RULE, Tutorial.Step.OUTRO:
				if key == KEY_SPACE or key == KEY_ENTER:
					tutorial.advance_step(self)
					queue_redraw()
				return

			Tutorial.Step.TEST_KEYS:
				var move_dir = player.get_move_direction(event)
				if move_dir != Vector2i.ZERO:
					tutorial.register_key_press(move_dir)
					var without_swap: bool = event.shift_pressed or Input.is_key_pressed(KEY_SHIFT)
					move_player(move_dir, without_swap)

				if (key == KEY_SPACE or key == KEY_ENTER) and tutorial.all_keys_tested():
					tutorial.advance_step(self)
					queue_redraw()
				return

			Tutorial.Step.SWAP_EXPLANATION:
				if key == KEY_SPACE or key == KEY_ENTER:
					tutorial.advance_step(self)
					queue_redraw()
					return

				var move_dir = player.get_move_direction(event)
				if move_dir != Vector2i.ZERO:
					var without_swap: bool = event.shift_pressed or Input.is_key_pressed(KEY_SHIFT)
					move_player(move_dir, without_swap)

			Tutorial.Step.SHIFT_EXPLANATION:
				if key == KEY_SPACE or key == KEY_ENTER:
					tutorial.advance_step(self)
					queue_redraw()
					return

				var move_dir = player.get_move_direction(event)
				if move_dir != Vector2i.ZERO:
					var without_swap: bool = event.shift_pressed or Input.is_key_pressed(KEY_SHIFT)
					if without_swap:
						move_player(move_dir, true)

		return

	if logic.state != GameLogic.State.PLAYING:
		if event.keycode == KEY_ESCAPE:
			get_tree().quit()
		elif event.keycode == KEY_R:
			if logic.state == GameLogic.State.GAME_OVER:
				logic.restart_full_game()
				lvl_mgr.current_level = 1
			else:
				logic.retry_level()
			start_level()
		elif (event.keycode == KEY_ENTER or event.keycode == KEY_SPACE) and logic.state == GameLogic.State.LEVEL_WON:
			logic.retry_level()
			lvl_mgr.current_level += 1
			start_level()
		return

	var move_dir = player.get_move_direction(event)
	if move_dir != Vector2i.ZERO:
		var without_swap: bool = event.shift_pressed or Input.is_key_pressed(KEY_SHIFT)
		move_player(move_dir, without_swap)

func move_player(dir: Vector2i, without_swap: bool = false) -> void:
	var target_pos = player.pos + dir

	if target_pos.x >= 0 and target_pos.x < grid_width and target_pos.y >= 0 and target_pos.y < grid_height:
		idle_timer.reset()

		if not without_swap:
			swap_colors(player.pos, target_pos)

		player.pos = target_pos

		if enemy and enemy.is_alive and (not tutorial.is_active or tutorial.is_enemy_visible()):
			if player.pos == enemy.pos:
				if not without_swap and grid_data[enemy.pos.x][enemy.pos.y] == enemy.color_idx:
					logic.win_level()
				else:
					logic.lose_life()
				queue_redraw()
				return

			enemy.make_move(player.pos, grid_data, grid_width, grid_height)
			
			if enemy.pos == player.pos:
				logic.lose_life()
				queue_redraw()
				return

		queue_redraw()

func swap_colors(from_pos: Vector2i, to_pos: Vector2i) -> void:
	var color_from = grid_data[from_pos.x][from_pos.y]
	var color_to = grid_data[to_pos.x][to_pos.y]

	grid_data[from_pos.x][from_pos.y] = color_to
	grid_data[to_pos.x][to_pos.y] = color_from

func _draw() -> void:
	var viewport_size = get_viewport_rect().size
	var current_cell_size = lvl_mgr.calculate_cell_size(viewport_size, Vector2i(grid_width, grid_height))
	
	var draw_enemy = enemy if (not tutorial.is_active or tutorial.is_enemy_visible()) else null
	
	SpriteDrawer.draw_game(self, grid_data, lvl_colors, grid_width, grid_height, current_cell_size, player, draw_enemy, lvl_mgr.current_level, logic)
	
	if tutorial and tutorial.is_active:
		tutorial.draw_overlay(self, viewport_size, current_cell_size, player, enemy)
