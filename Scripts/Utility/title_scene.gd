extends Control

@export var new_game_scene: StringName = &""

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_quit_button_pressed() -> void:
	get_tree().quit(0)


func _on_settings_button_pressed() -> void:
	pass # Replace with function body.


func _on_new_game_button_pressed() -> void:
	SceneLoader.load_scene(new_game_scene)
