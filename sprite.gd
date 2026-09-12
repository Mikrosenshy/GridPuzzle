class_name SpriteDrawer
extends RefCounted

static func draw_game(canvas: CanvasItem, grid_data: Array, lvl_colors: Array[Color], grid_width: int, grid_height: int, cell_size: Vector2, player: Player, enemy: Enemy, level_num: int, logic: GameLogic) -> void:
	var viewport_size = Vector2(canvas.get_window().size)
	var font = ThemeDB.fallback_font

	# 1. SPIELFELD (Raster)
	for x in range(grid_width):
		for y in range(grid_height):
			var color_idx = grid_data[x][y]
			var cell_color = lvl_colors[color_idx]
			var rect = Rect2(Vector2(x * cell_size.x, y * cell_size.y), cell_size)
			canvas.draw_rect(rect, cell_color)
			canvas.draw_rect(rect, Color.BLACK, false, 1.0)

	# 2. SPIELER
	if player:
		var p_rect = Rect2(
			Vector2(player.pos.x * cell_size.x + cell_size.x * 0.1, player.pos.y * cell_size.y + cell_size.y * 0.1),
			Vector2(cell_size.x * 0.8, cell_size.y * 0.8)
		)
		canvas.draw_texture_rect(Init.tex_player, p_rect, false)
		
		var shield_rect = Rect2(
			Vector2(player.pos.x * cell_size.x + cell_size.x * 0.55, player.pos.y * cell_size.y + cell_size.y * 0.55),
			Vector2(cell_size.x * 0.35, cell_size.y * 0.35)
		)
		canvas.draw_texture_rect(Init.tex_shield, shield_rect, false)

	# 3. GEGNER
	if enemy and enemy.is_alive:
		var e_rect = Rect2(
			Vector2(enemy.pos.x * cell_size.x + cell_size.x * 0.1, enemy.pos.y * cell_size.y + cell_size.y * 0.1),
			Vector2(cell_size.x * 0.8, cell_size.y * 0.8)
		)
		
		var tex_to_draw = enemy.texture if enemy.texture else Init.tex_enemy
		canvas.draw_texture_rect(tex_to_draw, e_rect, false)

		var bow_rect = Rect2(
			Vector2(enemy.pos.x * cell_size.x + cell_size.x * 0.55, enemy.pos.y * cell_size.y + cell_size.y * 0.1),
			Vector2(cell_size.x * 0.35, cell_size.y * 0.35)
		)
		canvas.draw_texture_rect(Init.tex_bow, bow_rect, false)

	# 4. SEITENLEISTE (RECHTS)
	var sidebar_x = viewport_size.x * Init.SIDEBAR_RATIO
	var sidebar_rect = Rect2(Vector2(sidebar_x, 0), Vector2(viewport_size.x * (1.0 - Init.SIDEBAR_RATIO), viewport_size.y))
	canvas.draw_rect(sidebar_rect, Init.COLOR_SIDEBAR_BG)
	canvas.draw_line(Vector2(sidebar_x, 0), Vector2(sidebar_x, viewport_size.y), Init.COLOR_TEXT_WHITE, 2.0)

	canvas.draw_string(font, Vector2(sidebar_x + 20, 50), "LEVEL " + str(level_num), HORIZONTAL_ALIGNMENT_LEFT, -1, 24, Init.COLOR_TEXT_WHITE)
	canvas.draw_string(font, Vector2(sidebar_x + 20, 100), "SCHILDE:", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color.LIGHT_GRAY)
	
	for i in range(logic.max_lives):
		var shield_color = Init.COLOR_TEXT_WHITE if i < logic.current_lives else Color(0.3, 0.3, 0.3, 0.4)
		var life_rect = Rect2(Vector2(sidebar_x + 20 + (i * 38), 115), Vector2(30, 30))
		canvas.draw_texture_rect(Init.tex_shield, life_rect, false, shield_color)

	# OPTIONS-BUTTON (MODE)
	var btn_w = viewport_size.x * 0.16
	var btn_h = 45.0
	var btn_x = sidebar_x + (viewport_size.x * (1.0 - Init.SIDEBAR_RATIO) - btn_w) / 2.0
	var btn_y = viewport_size.y - 70.0
	var button_rect = Rect2(Vector2(btn_x, btn_y), Vector2(btn_w, btn_h))

	canvas.draw_rect(button_rect, Init.COLOR_BUTTON_BG)
	canvas.draw_rect(button_rect, Init.COLOR_BORDER_CYAN, false, 2.0)
	var btn_text = "MODE: " + logic.get_current_difficulty_name()
	canvas.draw_string(font, Vector2(btn_x, btn_y + 28), btn_text, HORIZONTAL_ALIGNMENT_CENTER, btn_w, 16, Init.COLOR_TEXT_WHITE)

	# 5. TUTORIAL-BUTTON (?)
	var help_btn_x = viewport_size.x - 50.0
	var help_btn_y = 15.0
	var help_btn_rect = Rect2(Vector2(help_btn_x, help_btn_y), Vector2(35, 35))
	canvas.draw_rect(help_btn_rect, Init.COLOR_BUTTON_BG)
	canvas.draw_rect(help_btn_rect, Init.COLOR_BORDER_CYAN, false, 2.0)
	canvas.draw_string(font, Vector2(help_btn_x, help_btn_y + 25), "?", HORIZONTAL_ALIGNMENT_CENTER, 35, 20, Init.COLOR_TEXT_WHITE)

	# 6. OVERLAY-BILDSCHIRME
	if logic.state != GameLogic.State.PLAYING:
		var overlay_rect = Rect2(Vector2.ZERO, viewport_size)
		canvas.draw_rect(overlay_rect, Color(0, 0, 0, 0.75))

		var title_text = ""
		var sub_text = ""

		match logic.state:
			GameLogic.State.LEVEL_WON:
				title_text = "LEVEL GESCHAFFT!"
				sub_text = "[ENTER] / [LEERTASTE] - Nächstes Level"
			GameLogic.State.LEVEL_LOST:
				title_text = "SCHILD ZERSTÖRT!"
				sub_text = "[R] - Wiederholen    |    [ESC] - Beenden"
			GameLogic.State.GAME_OVER:
				title_text = "GAME OVER!"
				sub_text = "[R] - Neues Spiel    |    [ESC] - Beenden"

		canvas.draw_string(font, Vector2(0, viewport_size.y / 2.0 - 20), title_text, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 36, Init.COLOR_BORDER_CYAN)
		canvas.draw_string(font, Vector2(0, viewport_size.y / 2.0 + 30), sub_text, HORIZONTAL_ALIGNMENT_CENTER, viewport_size.x, 20, Init.COLOR_TEXT_WHITE)
