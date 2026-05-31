extends Node

@export var character_scene : PackedScene



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var player = character_scene.instantiate()
	player.position = $Marker3D.position
	add_child(player)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
