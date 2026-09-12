class_name Init
extends RefCounted

# --- SPIEL- & RASTER-GRENZEN ---
const MAX_GRID_SIZE: int = 8
const MAX_LIVES: int = 4
const SIDEBAR_RATIO: float = 0.8
const TUTORIAL_SAVE_PATH: String = "user://tutorial.cfg"

# --- SCHWIERIGKEITSGRADE & ZEITEN ---
const DIFFICULTIES: Array[String] = ["Anfänger", "Leicht", "Mittel", "Schwer"]
const FLEE_CHANCES: Array[float] = [0.04, 0.08, 0.18, 0.25]
const IDLE_TIME_LIMITS: Array[float] = [12.0, 8.0, 6.0, 4.0]
const DEFAULT_DIFFICULTY_IDX: int = 1

# --- FARBPALETTE & UI-FARBEN ---
const PALETTE: Array[Color] = [
	Color("e63946"), # Rot
	Color("457b9d"), # Blau
	Color("2a9d8f"), # Grün
	Color("e9c46a"), # Gelb
	Color("8b4513"), # Braun
	Color("40e0d0")  # Türkis
]

const COLOR_SIDEBAR_BG: Color = Color("1e1e24")
const COLOR_BUTTON_BG: Color = Color("2b2d42")
const COLOR_BORDER_CYAN: Color = Color.CYAN
const COLOR_TEXT_WHITE: Color = Color.WHITE
const COLOR_TEXT_YELLOW: Color = Color.YELLOW

# --- TEXTUREN & SPRITES ---
static var tex_player: Texture2D = preload("res://sprites/player.png")
static var tex_enemy: Texture2D = preload("res://sprites/enemy.png")
static var tex_shield: Texture2D = preload("res://sprites/player_shield.png")
static var tex_bow: Texture2D = preload("res://sprites/enemy_bow.png")
static var tex_arrow: Texture2D = preload("res://sprites/enemy_arrow.png")
