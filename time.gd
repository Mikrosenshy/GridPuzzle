class_name IdleTimer
extends RefCounted

var current_time: float = 0.0
var max_time: float = Init.IDLE_TIME_LIMITS[Init.DEFAULT_DIFFICULTY_IDX]

func set_difficulty(diff_idx: int) -> void:
	if diff_idx >= 0 and diff_idx < Init.IDLE_TIME_LIMITS.size():
		max_time = Init.IDLE_TIME_LIMITS[diff_idx]
	reset()

func reset() -> void:
	current_time = 0.0

func update(delta: float) -> bool:
	current_time += delta
	if current_time >= max_time:
		current_time = 0.0
		return true
	return false
