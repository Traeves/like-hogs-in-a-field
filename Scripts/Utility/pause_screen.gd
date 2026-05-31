extends Control

@onready var menu_scene = "uid://chwq3dix5m84b"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	GameManager.state_changed.connect(_on_game_state_changed)
	hide()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_game_state_changed(new_state: GameManager.GameState) -> void:
	if new_state == GameManager.GameState.PAUSED:
		show()
	else:
		hide()


func _on_continue_button_pressed() -> void:
	GameManager.change_state(GameManager.GameState.PLAYING)


func _on_save_button_pressed() -> void:
	pass # Replace with function body.


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_quit_button_pressed() -> void:
	SceneLoader.load_scene(menu_scene)
	await SceneLoader.load_finished
	GameManager.change_state(GameManager.GameState.MENU)
