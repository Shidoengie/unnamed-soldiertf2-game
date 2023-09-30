extends CharacterBody2D

var BodyAnimState : AnimationNodeStateMachinePlayback
@onready var BodyAnimTree := $BodyAnimationTree as AnimationTree
@onready var CrouchClipCheck := $CrouchClipCheck as ShapeCast2D
@onready var GUI := Global.DevGUI
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

@export var moveSpeed = 400.0

@onready var Camera := %Camera2d
@onready var Base_CameraPos = %Camera2d.position as Vector2
var launchVec : Vector2
var canShoot := true

@onready var AnimStates = %AnimStates
@onready var SpeedValues = %SpeedValues
@onready var SlideStates = %SlideStates
@onready var MoveStates = %MoveStates
@onready var GroundStates = %GroundStates

#A Boolean flag to store if the player can jump this is mainly used for coyote jumps
var canJump = true

#Coyote time variables
@export var coyoteTimerMax = 0.1
var coyoteTimer = 0.0

#enums for statemachines that handle most of the player logic


@onready var CameraValues = {
	CROUCH = Vector2(0,100) + Base_CameraPos,
	LOOK_DOWN = Vector2(0,100) + Base_CameraPos, LOOK_UP = Vector2(0,-100) + Base_CameraPos,
}

func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	Global.player = self
func _physics_process(delta):
	
#
	if not is_on_floor():
		velocity.y += gravity * delta
		velocity.y = clamp(velocity.y,-PlayerStats.terminalVelocity,PlayerStats.terminalVelocity)
		if SlideStates.current != SlideStates.LAUNCHED:
			SlideStates.current = SlideStates.ONAIR
		if coyoteTimer >= coyoteTimerMax:
			canJump = false
			coyoteTimer = 0
		else:
			coyoteTimer += delta
	else:
		coyoteTimer = 0
		canJump = true
		if SlideStates.current != SlideStates.CROUCH:
			SlideStates.current = SlideStates.ONGROUND

	var dev = [
	GroundStates.current_name,
	MoveStates.current_name,
	SlideStates.current_name,
	moveSpeed,
	velocity,
	"Position",
	global_position,
	"CanJump",canJump,
	AnimStates.current,
	Camera.position,
	delta,
	"IsonSeiling",
	"is_on_wall",
	is_on_wall()
	]
	DEV_GUI(dev)
	_stateChecks()
	_stateMachines(delta)
	move_and_slide()
	
# Function containing all statemachines

func _stateMachines(delta) -> void:

	var PREV_animState = AnimStates.current
	#Logic For handling landing
	#Checks if the player is touching the floor and if the player is in the falling or jumping stat
	if (GroundStates.current == GroundStates.FALL or GroundStates.current == GroundStates.JUMP) and is_on_floor():
		GroundStates.current = GroundStates.LAND
	GroundStates.stateMachine()
	MoveStates.stateMachine()
	if SlideStates.current == SlideStates.LAUNCHED:
		moveSpeed = PlayerStats.airSpeed+abs(launchVec.x)
	else:
		moveSpeed = SpeedValues.current
	if PREV_animState != AnimStates.current:
		BodyAnimState.travel(AnimStates.current)
func _stateChecks() -> void:
	
	_crouch()

	if Input.is_action_just_pressed("Jump") and canJump:
		GroundStates.current = GroundStates.JUST_JUMP

	if Input.is_action_pressed("MoveLeft"):
		MoveStates.current = MoveStates.LEFT
	if Input.is_action_just_pressed("MoveLeft"):
		scale.x = -1
	if Input.is_action_just_pressed("MoveRight"):
		scale.x = 1
	elif Input.is_action_pressed("MoveRight"):
		MoveStates.current = MoveStates.RIGHT
	#The function of the else is to check if the player is pressing any directional keys
	else:
		if is_on_floor() and round(abs(velocity.x)) == 0:
			MoveStates.current = MoveStates.STOPED
			velocity.x = 0
			return
		MoveStates.current = MoveStates.SLIDE

func _crouch():
#	if CrouchClipCheck.is_colliding() and SlideStates.current == SlideStates.ONAIR:
#		GroundStates.current = GroundStates.CROUCH
#		return
	if not is_on_floor():
		if GroundStates.current == GroundStates.CROUCH:
			GroundStates.current = GroundStates.FALL
		return
	SlideStates.current = SlideStates.ONGROUND
	
	canJump = false if CrouchClipCheck.is_colliding() and CrouchClipCheck.get_collider(0) else canJump
	
	if Input.is_action_pressed("Crouch"):
		GroundStates.current = GroundStates.CROUCH
	elif not CrouchClipCheck.is_colliding():
		GroundStates.current = GroundStates.ONGROUND



#Array parsing used for the Debug user interface
func DEV_GUI(varArr):
	var outString = ""
	for i in varArr:
		outString += str(i) + "\n"
	Global.DevGUI.groundstate = outString


func _on_tick_timeout():
	pass # Replace with function body.


