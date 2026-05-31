extends CharacterBody3D

@export_group("Speeds")
@export var base_speed : float = 5.0
@export var jump_velocity : float = 3.0
@export var sprint_speed : float = 7.5
@export var mouse_sensitivity : float = 0.5

@export_group("Inputs")
@export var forward : String = "move_forward"
@export var left : String = "move_left"
@export var right : String = "move_right"
@export var back : String = "move_back"
@export var jump : String = "jump"

# Need variable to know if we currently have control of the mouse
var mouse_captured: bool = false

@onready var head : Node3D =$Head

# Initialize the start look_rotation to whatever the player spawns in with
func _ready() -> void:
	GameManager.state_changed.connect(capture_mouse)
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	mouse_captured = true


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("pause"):
		release_mouse()
		GameManager.change_state(GameManager.GameState.PAUSED)
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed(jump) and is_on_floor():
		velocity.y = jump_velocity

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector(left, right, forward, back)
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * base_speed
		velocity.z = direction.z * base_speed
	else:
		velocity.x = move_toward(velocity.x, 0, base_speed)
		velocity.z = move_toward(velocity.z, 0, base_speed)

	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if mouse_captured:
			var mouse_delta = event.screen_relative
			head.rotation.x -= mouse_delta.y * mouse_sensitivity
			head.rotation.x = clamp(head.rotation.x, deg_to_rad(-85), deg_to_rad(85))
			rotation.y -= mouse_delta.x * mouse_sensitivity


func capture_mouse(current_state: GameManager.GameState) -> void:
	if(current_state == GameManager.GameState.PLAYING):
		if not mouse_captured:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
			mouse_captured = true


func release_mouse() -> void:
	if mouse_captured:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		mouse_captured = false
