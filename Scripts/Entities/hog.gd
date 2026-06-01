extends CharacterBody3D

enum HogState {
	GRAZE,
	WANDER,
	FLEE,
	DEAD,
}

@export_category("Speeds")
@export var walk_speed : float = 2.0
@export var max_wander_radius : float = 5.0
@export var run_speed : float = 5.0
@export var turn_speed: float = 5.0

@export_category("Herd Weights")
@export var seperation_weight: float = 1.5
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0
@export var flee_weight: float = 3.0 #Fleeing danger should be highest priority
## Age ranges from 0-10
@export var age: int = 10
@export var herd_center : Node3D

@onready var pivot = $Pivot
@onready var state_timer = $StateTimer
@onready var animation = $AnimationPlayer
@onready var herd_sensing = $HerdSensingArea
@onready var age_label = $AgeLabel

var current_state = HogState.GRAZE
var running_from : Node3D
var target_position : Vector3
var danger_position : Vector3
var neighbors : Array[CharacterBody3D]
var graze_radius


func _ready():
	state_timer.timeout.connect(_on_state_timer_timeout)
	#herd_sensing.body_entered.connect(_on_herd_sensing_body_entered)
	#herd_sensing.body_exited.connect(_on_herd_sensing_body_exited)
	age_label.text = str(age)
	find_herd_center()
	start_grazing()

func find_herd_center():
	if herd_center == null:
		var found_anchor = get_tree().get_first_node_in_group("HerdAnchors")
		var herd_anchors = get_tree().get_nodes_in_group("HerdAnchors")
		for anchors in herd_anchors:
			if found_anchor == anchors:
				continue
			if (
					anchors.global_position.distance_squared_to(global_position) 
					< found_anchor.global_position.distance_squared_to(global_position)
			):
				found_anchor = anchors
	else:
		graze_radius = herd_center.herd_radius
	graze_radius = herd_center.herd_radius


func _physics_process(delta: float):
	match current_state:
		HogState.GRAZE:
			velocity = Vector3.ZERO
		HogState.WANDER:
			var wander_direction = global_position.direction_to(target_position)
			wander_direction.y = 0
			
			var seperation_direction = Vector3.ZERO
			
			for neighbor in neighbors:
				if global_position.distance_squared_to(neighbor.global_position) < 2.0:
					seperation_direction += global_position.direction_to(neighbor.global_position)
			seperation_direction.y = 0
			
			var final_dir = (wander_direction.normalized() + (seperation_direction * 2.0)).normalized()
			velocity = final_dir * walk_speed
			
			if global_position.distance_squared_to(target_position) < 1.0:
				start_grazing()
		HogState.FLEE:
			var boids_direction = calculate_boids()
			var flee_direction = global_position.direction_to(danger_position) * -1
			flee_direction.y = 0
			
			var final_dir = (boids_direction + 
					(flee_direction.normalized() * flee_weight)).normalized()
			
			velocity = final_dir * run_speed
		HogState.DEAD:
			pass
	
	# Adding the gravity
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	move_and_slide()
	
	var horizontal_velocity = Vector3(velocity.x, 0, velocity.z)
	if horizontal_velocity.length_squared() > 0.01:
		#var look_target = global_position + horizontal_velocity
		#look_at(look_target, Vector3.UP)
		#var target_basis = Basis.looking_at(horizontal_velocity, Vector3.UP)
		#transform.basis = transform.basis.slerp(target_basis, turn_speed * delta)
		var target_rotation_y = atan2(-velocity.x, -velocity.z)
		pivot.rotation.y = lerp_angle(pivot.rotation.y, target_rotation_y, turn_speed * delta)


func calculate_boids() -> Vector3:
	if neighbors.is_empty():
		return Vector3.ZERO
	
	var seperation = Vector3.ZERO
	var alignment = Vector3.ZERO
	var center_of_mass = Vector3.ZERO
	
	var total_influence = 0.0
	
	for neighbor in neighbors:
		# Seperation
		if global_position.distance_squared_to(neighbor.global_position) < 4.0:
			seperation += global_position.direction_to(neighbor.global_position) * -1
		
		# Influence (Based on age)
		var influence = 1.0
		if neighbor.age > age:
			influence = 5.0
		elif neighbor.age < age:
			influence = 0.2
		
		# Alignment
		alignment += neighbor.velocity * influence
		
		# Cohesion
		center_of_mass += neighbor.global_position * influence
		
		total_influence += influence
	
	if total_influence > 0:
		alignment = alignment / total_influence
		center_of_mass = center_of_mass / total_influence
	
	var cohesion = global_position.direction_to(center_of_mass)
	
	var final_direction = (
		(seperation * seperation_weight) + 
		(alignment * alignment_weight) + 
		(cohesion * cohesion_weight)
	)
	
	final_direction.y = 0
	return final_direction.normalized()


func start_grazing():
	current_state = HogState.GRAZE
	#play grazing animation
	state_timer.start(randf_range(2.0,6.0))


func start_wandering():
	current_state = HogState.WANDER
	#play walking animation
	var random_offset = Vector3(
			randf_range(-graze_radius, graze_radius),
			0,
			randf_range(-graze_radius, graze_radius)
	)
	
	if herd_center:
		target_position = herd_center.global_position + random_offset
	else:
		target_position = global_position + random_offset
	
	state_timer.start(4.0)


func _on_state_timer_timeout():
	match current_state:
		HogState.GRAZE:
			start_wandering()
		HogState.WANDER:
			start_grazing()
		HogState.FLEE:
			start_grazing()
	

func _on_herd_sensing_body_entered(body):
	if body != self and body.is_in_group("Hogs"):
		neighbors.append(body)


func _on_herd_sensing_body_exited(body):
	if body in neighbors:
		neighbors.erase(body)
