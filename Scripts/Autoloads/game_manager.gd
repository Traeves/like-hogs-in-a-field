extends Node

enum GameState {
	MENU,
	PLAYING,
	PAUSED,
	GAME_OVER,
}

signal state_changed(new_state)

var current_state: GameState = GameState.MENU

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


func change_state(new_state: GameState) -> void:
	if current_state == new_state:
		return
	
	current_state = new_state
	
	state_changed.emit(current_state)
	
	match current_state:
		GameState.MENU:
			get_tree().paused = false
		GameState.PLAYING:
			get_tree().paused = false
		GameState.PAUSED:
			get_tree().paused = true
		GameState.GAME_OVER:
			get_tree().paused = true
