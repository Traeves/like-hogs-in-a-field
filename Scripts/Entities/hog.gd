extends CharacterBody3D

enum HogState {
	GRAZE,
	WANDER,
	PANICKED,
	DEAD,
}

@export_category("Speeds")
@export var wander_speed : float = 2.0
@export var max_wander_radius : float = 5.0
@export var panicked_speed : float = 5.0
@export var turn_speed: float = 5.0

@export_category("Herd Weights")
@export var seperation_weight: float = 1.5
@export var alignment_weight: float = 1.0
@export var cohesion_weight: float = 1.0

@onready var pivot = $Pivot
@onready var state_timer = $StateTimer
@onready var animation = $AnimationPlayer
@onready var stop_moving = $StopMovingTimer
@onready var graze = $GrazeTimer
@onready var panicked = $PanickedTimer

var current_state

var direction : Vector3 = Vector3.ZERO

var running_from : Node3D

var target_position : Vector3




func _ready() -> void:
	current_state = HogState.GRAZE
	state_timer.timeout.connect(_on_state_timer_timeout)


func _physics_process(delta: float) -> void:
	#var temp_velocity = Vector3.ZERO
	
	match current_state:
		HogState.GRAZE:
			velocity = Vector3.ZERO
		HogState.WANDER:
			direction = global_position.direction_to(target_position)
			
			direction.y = 0
			direction = direction.normalized()
			
			velocity = direction * wander_speed
			
			if global_position.distance_to(target_position) < 0.5:
				start_grazing()
		HogState.PANICKED:
			pass
		HogState.DEAD:
			pass
	
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


func start_grazing():
	current_state = HogState.GRAZE
	#play grazing animation
	state_timer.start(randf_range(2.0,6.0))


func start_wandering():
	current_state = HogState.WANDER
	#play walking animation
	var random_offset = Vector3(
		randf_range(-max_wander_radius, max_wander_radius),
		0,
		randf_range(-max_wander_radius, max_wander_radius)
	)
	target_position = global_position + random_offset
	
	state_timer.start(5.0)


func _on_state_timer_timeout():
	if current_state == HogState.GRAZE:
		start_wandering()
	elif current_state == HogState.WANDER:
		start_grazing()


#func _on_graze_timer_timeout() -> void:
	#direction.x = randf_range(-1.0, 1.0)
	#direction.z = randf_range(-1.0, 1.0)
	#stop_moving.start(randi_range(2, 5))


#func _on_stop_moving_timer_timeout() -> void:
	#direction = Vector3.ZERO
	#animation.play("idle")


#func _on_scare_detection_area_body_entered(body: Node3D) -> void:
	#var non_internal_groups = []
	#for group in body.get_groups():
		#if not str(group).begins_with('_'):
			#non_internal_groups.push_back(group)
	#if non_internal_groups.has("Player"):
		#graze.set_paused(true)
		#stop_moving.set_paused(true)
		#running_from = body
		#current_state = HogState.Panicked
		#direction = body.global_position.direction_to(global_position)


#func _on_scare_detection_area_body_exited(body: Node3D) -> void:
	#if body == running_from:
		#panicked.start()
		#print("Escaped")


#func _on_panicked_timer_timeout() -> void:
	#stop_moving.set_paused(false)
	#graze.set_paused(false)
	#current_state = HogState.Grazing
	#graze.timeout.emit()
