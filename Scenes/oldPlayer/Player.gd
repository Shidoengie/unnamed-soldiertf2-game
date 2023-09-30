extends CharacterBody2D

class_name player
var BodyAnimState : AnimationNodeStateMachinePlayback
@onready var BodyAnimTree := $BodyAnimationTree as AnimationTree
@onready var CrouchClipCheck := $CrouchClipCheck as ShapeCast2D
@onready var GUI := get_parent().find_child("GUI")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jumpForce := 500
@export var moveSpeed = 400.0
@export var airSpeed := 100.0
@export var stats:Resource
@onready var Camera := $Camera2d
@onready var Base_CameraPos = $Camera2d.position as Vector2
var launchVec : Vector2
var canShoot := true


#A Boolean flag to store if the player can jump this is mainly used for coyote jumps
var canJump = true

#Coyote time variables
@export var coyoteTimerMax = 0.1
var coyoteTimer = 0

#enums for statemachines that handle most of the player logic
const AnimStates = {
	RESET = "RESET",
	WALK = "Walk",
	JUMP = "Jump",
	LAND = "Land",
	FALL = "Fall" ,
	CROUCH_IDLE = "Crouch_idle",
	CROUCH_WALK = "Crouch_Walk",
}
var CUR_AnimState = AnimStates.RESET

enum MoveStates {
	LEFT, RIGHT,
	SLIDE, STOPED
}
var CUR_MoveState:MoveStates = MoveStates.STOPED

enum GroundStates {
	ONGROUND, LAND,
	FALL, JUST_FELL,
	JUMP, JUST_JUMP,
	CROUCH, RUN
}
var CUR_GroundState:GroundStates = GroundStates.ONGROUND

@onready var CameraValues = {
	CROUCH = Vector2(0,100) + Base_CameraPos,
	LOOK_DOWN = Vector2(0,100) + Base_CameraPos, LOOK_UP = Vector2(0,-100) + Base_CameraPos,
}

enum SpeedValues {
	WALK = 300,
	CROUCH = 100,
	RUN = 500
}
var CUR_SpeedValue = SpeedValues.WALK

enum SlideStates {LAUNCHED,ONAIR,ONGROUND,CROUCH}
var CUR_SlideState = SlideStates.ONGROUND

func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")

func _physics_process(delta:float):

#
	grav(delta)

	var dev = [
	GroundStates.keys()[CUR_GroundState],
	MoveStates.keys()[CUR_MoveState],
	SlideStates.keys()[CUR_SlideState],
	moveSpeed,
	velocity,
	"CanJump",canJump,
	CUR_AnimState,
	Camera.position,
	delta,
	"IsonSeiling"
	]
	DEV_GUI(dev)
	_stateChecks()
	_stateMachines(delta)
	move_and_slide()

# Function containing all statemachines
func grav(delta:float)->void:
	if is_on_floor():
		coyoteTimer = 0
		canJump = true
		if CUR_SlideState != SlideStates.CROUCH:
			CUR_SlideState = SlideStates.ONGROUND
		return
	velocity.y += gravity * delta
	if CUR_SlideState != SlideStates.LAUNCHED:
		CUR_SlideState = SlideStates.ONAIR

	if coyoteTimer >= coyoteTimerMax:
		canJump = false
		coyoteTimer = 0
	else:
		coyoteTimer += delta

func _stateMachines(delta) -> void:

	var PREV_animState = CUR_AnimState
	#Logic For handling landing
	#Checks if the player is touching the floor and if the player is in the falling or jumping state

	if (CUR_GroundState == GroundStates.FALL or CUR_GroundState == GroundStates.JUMP) and is_on_floor():
		CUR_GroundState = GroundStates.LAND
	
	_groundMachine(CUR_GroundState)
	_moveMachine(CUR_MoveState)
	#Statemachine for handling horizontal movement along with interpolation for smooth movement
#end of statemachines
	if CUR_SlideState == SlideStates.LAUNCHED:
		moveSpeed = airSpeed+abs(launchVec.x)
	else:
		moveSpeed = CUR_SpeedValue
	if PREV_animState != CUR_AnimState:
		BodyAnimState.travel(CUR_AnimState)
func _moveMachine(state:MoveStates) -> void:
	match state:
		MoveStates.LEFT:
			if CUR_SlideState == SlideStates.LAUNCHED and round(launchVec.x) > 0:
				CUR_SlideState = SlideStates.ONGROUND
			$Sprite2d.flip_h = true
			velocity.x = lerp(velocity.x,float(-moveSpeed),0.1)
		MoveStates.RIGHT:
			if CUR_SlideState == SlideStates.LAUNCHED and round(launchVec.x) < 0:
				#Same thing as Left but in an oposite direction
				CUR_SlideState = SlideStates.ONGROUND
			$Sprite2d.flip_h = false
			velocity.x = lerp(velocity.x,float(moveSpeed),0.1)

		MoveStates.SLIDE:
			if not is_on_floor() and CUR_SlideState == SlideStates.LAUNCHED:
				#Checks if it isnt on the floor to alow for acurate rocket arches
				CUR_MoveState = MoveStates.STOPED
				return
			_slideMachine(CUR_SlideState)
func _slideMachine(state:SlideStates)->void:
	match state:
		SlideStates.ONGROUND:
			velocity.x = lerp(velocity.x,0.0,0.5)
		SlideStates.ONAIR:
			velocity.x = lerp(velocity.x,0.0,0.1)
		SlideStates.CROUCH:
			velocity.x = lerp(velocity.x,0.0,0.5)
func _groundMachine(state:GroundStates) -> void:
	match state:
		#A single fire state used to apply the jump foce which makes the player jump
		GroundStates.JUST_JUMP:
			velocity.y = -jumpForce
			CUR_GroundState = GroundStates.JUMP
			CUR_AnimState = AnimStates.JUMP

		GroundStates.FALL:
			CUR_AnimState = AnimStates.FALL

		#Handles if the player has landed just touched the ground
		GroundStates.FALL or GroundStates.JUMP:
			if is_on_floor():
				CUR_GroundState = GroundStates.LAND

		#A single fire state used to trigger reloading and restarting the coyote timer
		GroundStates.LAND:
			CUR_GroundState = GroundStates.ONGROUND
			canJump = true
			CUR_AnimState = AnimStates.LAND

		#groundstate for handling fall detection and onground animations
		GroundStates.ONGROUND:

			canJump = true
			if not is_on_floor():
				CUR_GroundState = GroundStates.FALL
			CUR_SpeedValue = SpeedValues.WALK
			CUR_SlideState = SlideStates.ONGROUND
			CUR_AnimState = AnimStates.WALK \
				if CUR_MoveState != MoveStates.STOPED\
				else AnimStates.RESET
		GroundStates.CROUCH:
			CUR_SlideState = SlideStates.CROUCH
			CUR_SpeedValue = SpeedValues.CROUCH
			CUR_AnimState = AnimStates.CROUCH_WALK \
				if CUR_MoveState != MoveStates.STOPED \
				else AnimStates.CROUCH_IDLE
			Camera.position = CameraValues.CROUCH
		_:
			pass

#Input Handling and checks to trigger states
func _stateChecks() -> void:

	if Input.is_action_pressed("look_down"):
		Camera.position = CameraValues.LOOK_DOWN
	elif Input.is_action_pressed("look_up"):
		Camera.position = CameraValues.LOOK_UP
	elif CUR_GroundState != GroundStates.CROUCH:
		Camera.position = Base_CameraPos

	_crouch()

	if Input.is_action_just_pressed("Jump") and canJump:
		CUR_GroundState = GroundStates.JUST_JUMP

	if Input.is_action_pressed("MoveLeft"):
		CUR_MoveState = MoveStates.LEFT
		return
	if Input.is_action_pressed("MoveRight"):
		CUR_MoveState = MoveStates.RIGHT
		return
	if is_on_floor() and round(abs(velocity.x)) == 0:
		CUR_MoveState = MoveStates.STOPED
		velocity.x = 0
		return
	CUR_MoveState = MoveStates.SLIDE

func _crouch():
	if not is_on_floor():
		if CUR_GroundState == GroundStates.CROUCH:
			CUR_GroundState = GroundStates.FALL
		return

	CUR_SlideState = SlideStates.ONGROUND
	canJump = false if CrouchClipCheck.is_colliding() else canJump
	if Input.is_action_pressed("Crouch"):
		CUR_GroundState = GroundStates.CROUCH
	elif not CrouchClipCheck.is_colliding():
		CUR_GroundState = GroundStates.ONGROUND


#Array parsing used for the Debug user interface
func DEV_GUI(varArr):
	var outString = ""
	for i in varArr:
		outString += str(i) + "\n"
	GUI.groundstate = outString



func _on_tick_timeout():
	pass # Replace with function body.


