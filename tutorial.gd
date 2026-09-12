class_name Tutorial
extends RefCounted

enum Step {
	MARK_PLAYER,
	TEST_KEYS,
	SWAP_EXPLANATION,
	SHIFT_EXPLANATION,
	INTRO_ENEMY,
	ENEMY_RULE_1,
	ENEMY_RULE_2,
	IDLE_RULE,
	OUTRO,
	FINISHED
}

var current_step: Step = Step.MARK_PLAYER
var is_active: bool = false
var has_been_completed: bool = false

var keys_pressed = {
	"up": false,
	"down": false,
	"left": false,
	"right": false
}

func _init() -> void:
	load_completion_status()

func save_completion_status() -> void:
	var config = ConfigFile.new()
	config.set_value("tutorial", "completed", true)
	config.save(Init.TUTORIAL_SAVE_PATH)
	has_been_completed = true

func load_completion_status() -> void:
	var config = ConfigFile.new()
	var err = config.load(Init.TUTORIAL_SAVE_PATH)
	if err == OK:
		has_been_completed = config.get_value("tutorial", "completed", false)
	else:
		has_been_completed = false

func start_tutorial(main_scene: Node2D) -> void:
	current_step = Step.MARK_PLAYER
	is_active = true
	keys_pressed["up"] = false
	keys_pressed["down"] = false
	keys_pressed["left"] = false
	keys_pressed["right"] = false
	if main_scene.has_method("setup_tutorial_start"):
		main_scene.setup_tutorial_start()

func cancel_tutorial() -> void:
	current_step = Step.FINISHED
	is_active = false
	save_completion_status()

func is_enemy_visible() -> bool:
	return current_step >= Step.INTRO_ENEMY and current_step != Step.FINISHED

func is_timer_active() -> bool:
	return current_step == Step.FINISHED

func all_keys_tested() -> bool:
	return keys_pressed["up"] and keys_pressed["down"] and keys_pressed["left"] and keys_pressed["right"]

func register_key_press(dir: Vector2i) -> void:
	if current_step == Step.TEST_KEYS:
		if dir.y < 0: keys_pressed["up"] = true
		elif dir.y > 0: keys_pressed["down"] = true
		elif dir.x < 0: keys_pressed["left"] = true
		elif dir.x > 0: keys_pressed["right"] = true

func advance_step(main_scene: Node2D) -> void:
	match current_step:
		Step.TEST_KEYS:
			if not all_keys_tested():
				return
			current_step = Step.SWAP_EXPLANATION
		Step.SHIFT_EXPLANATION:
			current_step = Step.INTRO_ENEMY
			if main_scene.has_method("setup_tutorial_enemy_spawn"):
				main_scene.setup_tutorial_enemy_spawn()
		Step.OUTRO:
			cancel_tutorial()
		_:
			if current_step < Step.OUTRO:
				current_step = (current_step + 1) as Step

func draw_overlay(canvas: CanvasItem, viewport_size: Vector2, cell_size: Vector2, player: Player, enemy: Enemy) -> void:
	if not is_active:
		return

	var font = ThemeDB.fallback_font
	var text_main = ""
	var text_sub = "[LEERTASTE] - Weiter    |    [ESC] - Abbrechen"

	match current_step:
		Step.MARK_PLAYER:
			text_main = "Das bist Du! (Gelb markiert)"
			var p_center = Vector2(player.pos.x * cell_size.x + cell_size.x / 2.0, player.pos.y * cell_size.y + cell_size.y / 2.0)
			canvas.draw_circle(p_center, min(cell_size.x, cell_size.y) * 0.5, Color(1, 1, 0, 0.4))
			canvas.draw_circle(p_center, min(cell_size.x, cell_size.y) * 0.5, Color.YELLOW, false, 3.0)

		Step.TEST_KEYS:
			text_main = "Bewege Dich mit [W], [A], [S], [D] oder den Pfeiltasten."
			if all_keys_tested():
				text_sub = "Super! [LEERTASTE] - Weiter    |    [ESC] - Abbrechen"
			else:
				text_sub = "Drücke alle 4 Richtungen!    |    [ESC] - Abbrechen"
			draw_key_indicators(canvas, viewport_size, font)

		Step.SWAP_EXPLANATION:
			text_main = "Beim Bewegen wird die Farbe des Zielfeldes mit Deinem Feld vertauscht. Probiere es aus!"

		Step.SHIFT_EXPLANATION:
			text_main = "Hältst Du [SHIFT] gedrückt, wechselt die Farbe beim Gehen NICHT. Probiere es aus! ([SHIFT] + W/A/S/D)"

		Step.INTRO_ENEMY:
			text_main = "Du bist nicht alleine hier... Ein Gegner trachtet Dir nach Deinem kostbaren Leben!"

		Step.ENEMY_RULE_1:
			text_main = "Der Hintergrund des Gegners zeigt seine 'verbotene' Farbe! Dieses Feld kann er NICHT betreten! Hast Du dieselbe Farbe unter Dir und trittst auf ihn, vernichtest Du ihn!"
			if enemy:
				var e_center = Vector2(enemy.pos.x * cell_size.x + cell_size.x / 2.0, enemy.pos.y * cell_size.y + cell_size.y / 2.0)
				canvas.draw_circle(e_center, min(cell_size.x, cell_size.y) * 0.6, Color(1, 0, 0, 0.4))

		Step.ENEMY_RULE_2:
			text_main = "Trittst Du mit einer ANDEREN Farbe auf das Feld des Gegners... nun ja, Du wirst es schon herausfinden!"

		Step.IDLE_RULE:
			text_main = "Wenn Du Dich zu lange nicht bewegst, kommt der Gegner näher... und bestimmt nicht, um Dich zu umarmen!"

		Step.OUTRO:
			text_main = "So, genug geredet..."
			text_sub = "Drücke [ENTER] oder [LEERTASTE], um das Spiel zu starten!"

	var box_w = viewport_size.x * 0.75
	var box_h = 125.0
	var box_x = (viewport_size.x * Init.SIDEBAR_RATIO - box_w) / 2.0
	var box_y = 15.0
	var box_rect = Rect2(Vector2(box_x, box_y), Vector2(box_w, box_h))

	canvas.draw_rect(box_rect, Color(0, 0, 0, 0.85))
	canvas.draw_rect(box_rect, Init.COLOR_BORDER_CYAN, false, 2.0)

	var font_size_main = 15 if viewport_size.x < 800 else 17

	canvas.draw_multiline_string(font, Vector2(box_x + 15, box_y + 25), text_main, HORIZONTAL_ALIGNMENT_LEFT, box_w - 30, font_size_main, -1, Init.COLOR_TEXT_WHITE)
	canvas.draw_string(font, Vector2(box_x + 15, box_y + box_h - 15), text_sub, HORIZONTAL_ALIGNMENT_RIGHT, box_w - 30, 14, Init.COLOR_TEXT_YELLOW)

func draw_key_indicators(canvas: CanvasItem, viewport_size: Vector2, font: Font) -> void:
	var start_x = viewport_size.x * 0.35
	var start_y = viewport_size.y - 180.0
	var size = 32.0

	var keys = [
		{"label": "W", "pressed": keys_pressed["up"], "pos": Vector2(start_x + size, start_y)},
		{"label": "A", "pressed": keys_pressed["left"], "pos": Vector2(start_x, start_y + size + 5)},
		{"label": "S", "pressed": keys_pressed["down"], "pos": Vector2(start_x + size, start_y + size + 5)},
		{"label": "D", "pressed": keys_pressed["right"], "pos": Vector2(start_x + size * 2, start_y + size + 5)}
	]

	for k in keys:
		var rect = Rect2(k["pos"], Vector2(size, size))
		var bg_col = Color.RED if k["pressed"] else Init.COLOR_BUTTON_BG
		canvas.draw_rect(rect, bg_col)
		canvas.draw_rect(rect, Init.COLOR_TEXT_WHITE, false, 1.0)
		canvas.draw_string(font, k["pos"] + Vector2(0, 22), k["label"], HORIZONTAL_ALIGNMENT_CENTER, size, 16, Init.COLOR_TEXT_WHITE)
