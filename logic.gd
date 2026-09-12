class_name GameLogic
extends RefCounted

enum State { PLAYING, LEVEL_WON, LEVEL_LOST, GAME_OVER }

var state: State = State.PLAYING
var max_lives: int = Init.MAX_LIVES
var current_lives: int = Init.MAX_LIVES
var current_diff_idx: int = Init.DEFAULT_DIFFICULTY_IDX

func get_current_flee_chance() -> float:
	return Init.FLEE_CHANCES[current_diff_idx]

func get_current_difficulty_name() -> String:
	return Init.DIFFICULTIES[current_diff_idx]

func cycle_difficulty() -> float:
	current_diff_idx = (current_diff_idx + 1) % Init.DIFFICULTIES.size()
	return get_current_flee_chance()

func lose_life() -> void:
	current_lives -= 1
	if current_lives <= 0:
		state = State.GAME_OVER
	else:
		state = State.LEVEL_LOST

func win_level() -> void:
	state = State.LEVEL_WON

func retry_level() -> void:
	state = State.PLAYING

func restart_full_game() -> void:
	current_lives = max_lives
	state = State.PLAYING
