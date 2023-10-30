extends CharacterBody3D


var SPEED = 5.0
const JUMP_VELOCITY = 4.5
var SENSITIVITY = 0.08

const SWAY = 10
const VSWAY = 10

const BOB_FREQ = 2.6
const BOB_AMP = 0.1
var t_bob = 0.0

var walking = false

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Head
@onready var hand = $Head/Hand
@onready var handloc = $Head/HandLoc
@onready var camera = $Head/Camera
@onready var footsteps = $Footsteps

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	hand.set_as_top_level(true)

func _input(event):
	if event is InputEventMouseMotion:
		head.rotation_degrees.x -= event.relative.y * SENSITIVITY
		head.rotation_degrees.x = clamp(head.rotation_degrees.x, -90, 90)
		rotation_degrees.y -= event.relative.x * SENSITIVITY

func _process(delta):
	hand.global_transform.origin = handloc.global_transform.origin
	hand.rotation.y = lerp_angle(hand.rotation.y, rotation.y, SWAY * delta)
	hand.rotation.x = lerp_angle(hand.rotation.x, head.rotation.x, VSWAY * delta)

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Capturing/Freeing the cursor
	if Input.is_action_just_pressed("escape"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

	t_bob += delta * velocity.length() * float(is_on_floor())
	$Head/Camera.transform.origin = _headbob(t_bob)

	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
		footsteps.stop()

	# Run
	if Input.is_action_pressed("run"):
		SPEED = 8.0
		footsteps.pitch_scale = 1.5
		footsteps.volume_db = -20
	if Input.is_action_just_released("run"):
		SPEED = 5.0
		footsteps.pitch_scale = 1
		footsteps.volume_db = -25

	# Silent Walk
	if Input.is_action_pressed("silent"):
		SPEED = 3.0
		footsteps.pitch_scale = 0.75
		footsteps.volume_db = -30
	if Input.is_action_just_released("silent"):
		SPEED = 5.0
		footsteps.pitch_scale = 1.0
		footsteps.volume_db = -25

	var input_dir = Input.get_vector("left", "right", "up", "down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	if input_dir.x != 0 or input_dir.y != 0:
		walking = true
	else:
		walking = false
	
	if walking and is_on_floor() and !footsteps.playing:
		footsteps.play()
	elif (!walking or !is_on_floor()) and footsteps.playing:
		footsteps.stop()

	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO
	pos.y = sin(time * BOB_FREQ) * BOB_AMP
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP
	return pos
