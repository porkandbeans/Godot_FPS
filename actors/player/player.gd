extends KinematicBody

const MIN_CAMERA_ANGLE = -90
const MAX_CAMERA_ANGLE = 90
const GRAVITY = -20

# looking sensitivity
export var camera_sensitivity: float = 0.08
export var move_speed: float = 20.0

# this var is for smooth movement
export var acceleration: float = 6.0
export var jump_impulse: float = 12.0

var velocity: Vector3 = Vector3.ZERO

onready var head: Spatial = $Head

# _ready is triggered just before the first frame is rendered
func _ready():
	# hide/capture the cursor for first-person mouse movement
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 

# for handing physics properties every frame (not to be confused with _process)
func _physics_process(delta):
	var movement = _get_movement_direction()
	
	# WASD
	velocity.x = lerp(velocity.x, movement.x * move_speed,acceleration * delta)
	velocity.z = lerp(velocity.z,movement.z * move_speed,acceleration * delta)
	
	# gravity
	velocity.y += GRAVITY * delta

	# put this back for solid movement
	# velocity = movement * move_speed
	velocity = move_and_slide(velocity,Vector3.UP)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		_handle_camera_rotation(event)
		
func _handle_camera_rotation(event):
	# rotate the pillbody and rotate the camera's parent (head)
	rotate_y(deg2rad(-event.relative.x * camera_sensitivity))
	head.rotate_x(deg2rad(-event.relative.y * camera_sensitivity))
	
	# clamp to 180 degrees of head up/down rotation
	head.rotation.x = clamp(head.rotation.x, deg2rad(MIN_CAMERA_ANGLE), deg2rad(MAX_CAMERA_ANGLE))
	
func _get_movement_direction():
	var direction = Vector3.DOWN
	
	if Input.is_action_pressed("forward"):
		direction -= transform.basis.z
	if Input.is_action_pressed("backwards"):
		direction += transform.basis.z
	if Input.is_action_pressed("left"):
		direction -= transform.basis.x
	if Input.is_action_pressed("right"):
		direction += transform.basis.x
	if Input.is_action_pressed("jump") and is_on_floor():
		velocity.y = jump_impulse
	
	# kills strafe-moving
	return direction.normalized()
