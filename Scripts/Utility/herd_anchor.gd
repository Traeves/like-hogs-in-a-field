extends Marker3D

enum HerdType {
	## Larger group (5-20) with an elder matriarch leading
	SOUNDERS,
	## Smaller group (2-5) with mature adult males
	BACHELOR
}

@export var animal_scene: PackedScene
@export var herd_size: int = 15
@export var herd_radius: float = 15.0
@export var herd_type: HerdType = HerdType.SOUNDERS

func _ready() -> void:
	for i in range(herd_size):
		var new_animal = animal_scene.instantiate()
		new_animal.herd_center = self
		if i < herd_size * 0.2:
			new_animal.age = randi_range(8, 10)
		elif i < herd_size * 0.6:
			new_animal.age = randi_range(3, 7)
		else:
			new_animal.age = randi_range(0, 4)
		
		var random_pos = Vector3(randf_range(-herd_radius, herd_radius),
				0, 
				randf_range(-herd_radius, herd_radius))
		
		new_animal.position = global_position + random_pos
		
		get_parent().add_child.call_deferred(new_animal)
