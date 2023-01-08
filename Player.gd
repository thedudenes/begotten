extends CharacterBody3D

@onready var armature = $Armature
@onready var spring_arm_pivot = $SpringArmPivot
@onready var spring_arm = $SpringArmPivot/SpringArm
@onready var anim_tree = $AnimationTree
@onready var camera = $SpringArmPivot/SpringArm/Camera3D

const SPEED = 2.0
const DASH_DISTANCE = 35
const LERP_VAL = .30
const CAMERA_SPEED = 0.05
const RUN_SPEED = 8.0

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):
	
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
	
	if event is InputEventMouseMotion:
		spring_arm_pivot.rotate_y(-event.relative.x * .005)
		spring_arm.rotate_x(-event.relative.y * .005)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
	

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta
		
	var input_run = Input.is_action_just_pressed("run")
	var input_dir = Input.get_vector("left", "right", "forward", "back")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	
	
	var input_camera = Input.get_vector("rot_left", "rot_right", "up", "down")
	
	direction = direction.rotated(Vector3.UP, spring_arm_pivot.rotation.y)
	
	if direction:
		velocity.x = lerp(velocity.x, direction.x * SPEED, LERP_VAL)
		velocity.z = lerp(velocity.z, direction.z * SPEED, LERP_VAL)
		
		if Input.is_action_pressed("run"):
			velocity.x = lerp(velocity.x, direction.x * RUN_SPEED, LERP_VAL)
			velocity.z = lerp(velocity.z, direction.z * RUN_SPEED, LERP_VAL)
			
			anim_tree.set("parameters/blendWalkRun/blend_amount", velocity.length() / RUN_SPEED)
		
		if Input.is_action_just_pressed("dash"):
			velocity.x = direction.x * DASH_DISTANCE
			velocity.z = direction.z * DASH_DISTANCE
	
		armature.rotation.y = lerp_angle(armature.rotation.y, atan2(-velocity.x, -velocity.z), LERP_VAL)
	else:
		velocity.x = lerp(velocity.x, 0.0, LERP_VAL)
		velocity.z = lerp(velocity.z, 0.0, LERP_VAL)
		
		anim_tree.set("parameters/blendWalkRun/blend_amount", 0)
	
	if input_camera:
		spring_arm_pivot.rotate_y(-input_camera.x * CAMERA_SPEED)
		spring_arm.rotate_x(-input_camera.y * CAMERA_SPEED)
		spring_arm.rotation.x = clamp(spring_arm.rotation.x, -PI/4, PI/4)
		
	anim_tree.set("parameters/blendWalkRun/blend_amount", 0)
	anim_tree.set("parameters/BlendSpace1D/blend_position", velocity.length() / SPEED)
	
	move_and_slide()
