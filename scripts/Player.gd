extends CharacterBody3D

var current_speed = 5.0

const JUMP_VELOCITY = 5.5
const WALK_SPEED = 5.0
const SPRINT_SPEED = 8.0
const CROUCH_SPEED = 3.0

const MOUSE_SENS = 0.5

var lerp_speed = 10.0
var direction = Vector3.ZERO
var crouching_depth = -0.5

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var head = $Pivot
@onready var standcolli = $StandingColli
@onready var crouchcolli = $CrouchColli

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if event is InputEventMouseMotion:
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
		head.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENS))
		head.rotation.x = clamp(head.rotation.x, deg_to_rad(-89), deg_to_rad(89))

func _physics_process(delta):
	if Input.is_action_pressed("crouch"):
		current_speed = CROUCH_SPEED
		head.position.y = lerp(head.position.y, 1.8 + crouching_depth, delta*lerp_speed)
		standcolli.disabled = true;
		crouchcolli.disabled = false;
	else:
		standcolli.disabled = false;
		crouchcolli.disabled = true;
		head.position.y = lerp(head.position.y, 1.8, delta*lerp_speed)
		if Input.is_action_pressed("sprint"):
			current_speed = SPRINT_SPEED
		else:
			current_speed = WALK_SPEED

	#Add gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	#Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	#Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("left", "right", "up", "down")
	direction = lerp(direction, (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized(), delta*lerp_speed)
	if direction:
		velocity.x = direction.x * current_speed
		velocity.z = direction.z * current_speed
	else:
		velocity.x = move_toward(velocity.x, 0, current_speed)
		velocity.z = move_toward(velocity.z, 0, current_speed)

	move_and_slide()
