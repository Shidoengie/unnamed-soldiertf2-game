extends CharacterBody2D


var BodyAnimState : AnimationNodeStateMachinePlayback
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GUI = get_parent().find_child("GUI")
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jumpForce = 300
@export var walkSpeed = 400.0
@export var airSpeed = 100.0

var base_walkSpeed
var launchVec : Vector2
var canShoot = true


#A Boolean flag to store if the player can jump this is mainly used for coyote jumps
var canJump = true

#Coyote time variables
@export var coyoteTimerMax = 5
var coyoteTimer = 0

#enums for statemachines that handle most of the player logic
const AnimStates = {  RESET = "RESET", WALK = "Walk", JUMP = "Jump", LAND = "Land", FALL = "Fall"}
var CUR_AnimState = AnimStates.RESET

enum MoveStates {LEFT,RIGHT,SLIDE,STOPED}
var CUR_MoveState = MoveStates.STOPED

enum GroundStates {ONGROUND,JUST_FELL,FALL,JUMP,JUST_JUMP,LAND}
var CUR_GroundState = GroundStates.ONGROUND

enum SpeedStates {LAUNCHED,ONAIR,ONGROUND}
var CUR_SpeedState = SpeedStates.ONGROUND
func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	base_walkSpeed = walkSpeed
func _physics_process(delta):

	if not is_on_floor():
		if CUR_SpeedState != SpeedStates.LAUNCHED:
			CUR_SpeedState = SpeedStates.ONAIR
		velocity.y += gravity * delta
		if coyoteTimer >= coyoteTimerMax:
			canJump = false
			coyoteTimer = coyoteTimerMax
		else:
			coyoteTimer += 1
	else:
		CUR_SpeedState = SpeedStates.ONGROUND
		coyoteTimer = 0
		canJump = true
	var dev = [
		GroundStates.keys()[CUR_GroundState],
		MoveStates.keys()[CUR_MoveState],
		SpeedStates.keys()[CUR_SpeedState],
		walkSpeed,
		velocity,
		"CanJump",canJump,
		CUR_AnimState,
		]
	DEV_GUI(dev)
	_stateChecks()
	_stateMachines(delta)
	move_and_slide()
	
# Function containing all statemachines

func _stateMachines(delta) -> void:
	
	#Logic For handling landing
	#Checks if the player is touching the floor and if the player is in the falling or jumping state
	
	if (CUR_GroundState == GroundStates.FALL or CUR_GroundState == GroundStates.JUMP) and is_on_floor():
		CUR_GroundState = GroundStates.LAND
	
	#Statemachine for handling horizontal movement along with interpolation for smooth movement
	match CUR_MoveState:
		MoveStates.LEFT:
			if CUR_SpeedState == SpeedStates.LAUNCHED and round(launchVec.x) > 0:
				#Checks if the player has been launched by an explosion and if its going the oposite way
				#then setting launched to false which resets the walkspeed
				CUR_SpeedState = SpeedStates.ONGROUND
			
			$Sprite2d.flip_h = true
			velocity.x = lerp(velocity.x,float(-walkSpeed),0.1)
			
		MoveStates.RIGHT:
			if CUR_SpeedState == SpeedStates.LAUNCHED and round(launchVec.x) < 0:
				#Same thing as Left but in an oposite direction 
				CUR_SpeedState = SpeedStates.ONGROUND
			$Sprite2d.flip_h = false
			velocity.x = lerp(velocity.x,float(walkSpeed),0.1)
			
		MoveStates.SLIDE:
			if not is_on_floor() and CUR_SpeedState == SpeedStates.LAUNCHED:
				#Checks if it isnt on the floor to alow for acurate rocket arches
				CUR_MoveState = MoveStates.STOPED
				return
			match CUR_SpeedState:
				SpeedStates.ONGROUND:
					velocity.x = lerp(velocity.x,0.0,0.5)
				SpeedStates.ONAIR:
					velocity.x = lerp(velocity.x,0.0,0.1)
				_:
					pass
	
	match CUR_GroundState:
		
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
			CUR_SpeedState = SpeedStates.ONGROUND
			if CUR_MoveState != MoveStates.STOPED:
				CUR_AnimState = AnimStates.WALK
			else:
				CUR_AnimState = AnimStates.RESET
	
	if CUR_SpeedState == SpeedStates.LAUNCHED:
		walkSpeed = airSpeed+abs(launchVec.x)
	else:
		walkSpeed = base_walkSpeed
		
	BodyAnimState.travel(CUR_AnimState)

#Input Handling and some otherchecks to trigger states
func _stateChecks() -> void:
	
	if Input.is_action_just_pressed("Jump") and canJump:
		CUR_GroundState = GroundStates.JUST_JUMP
		
	if Input.is_action_pressed("MoveLeft"):
		CUR_MoveState = MoveStates.LEFT
		
	elif Input.is_action_pressed("MoveRight"):
		CUR_MoveState = MoveStates.RIGHT
		
	else:
		if is_on_floor():
			if round(abs(velocity.x)) == 0:
				CUR_MoveState = MoveStates.STOPED
				return
			CUR_MoveState = MoveStates.SLIDE
		else:
			CUR_MoveState = MoveStates.SLIDE
#Array parsing used for the Debug user interface
func DEV_GUI(varArr ):
	var outString = ""
	for i in varArr:
		outString += str(i) + "\n"
	GUI.groundstate = outString
