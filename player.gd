class_name Player
extends RefCounted

var pos: Vector2i = Vector2i(0, 0)

func _init(start_pos: Vector2i = Vector2i(0, 0)) -> void:
	pos = start_pos

func get_move_direction(event: InputEvent) -> Vector2i:
	var move_dir = Vector2i.ZERO
	if event.is_action_pressed("ui_right") or event.keycode == KEY_D:
		move_dir.x += 1
	elif event.is_action_pressed("ui_left") or event.keycode == KEY_A:
		move_dir.x -= 1
	elif event.is_action_pressed("ui_down") or event.keycode == KEY_S:
		move_dir.y += 1
	elif event.is_action_pressed("ui_up") or event.keycode == KEY_W:
		move_dir.y -= 1
	return move_dir
