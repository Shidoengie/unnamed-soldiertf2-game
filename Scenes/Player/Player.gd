extends CharacterBody2D


var BodyAnimState : AnimationNodeStateMachinePlayback
var GunAnimState : AnimationNodeStateMachinePlayback
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GunAnim = $GunAnim as AnimationPlayer
@onready var GUI = get_parent().find_child("GUI")
@onready var rocket = preload("res://Scenes/Rocket/Rocket.tscn")
@onready var ReloadTimer = $ReloadTimer as Timer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jumpForce = 300
@export var walkSpeed = 400.0
@export var airSpeed = 100.0

var walkSpeedmax
var launched = false
var launchVec : Vector2
var canShoot = true

var ammo = 3
var maxAmmo = 3

#A Boolean flag to store if the player can jump this is mainly used for coyote jumps
var canJump = true

#Coyote time variables
@export var coyoteTimerMax = 5
var coyoteTimer = 0

const AnimStates = {  RESET = "RESET", WALK = "Walk", JUMP = "Jump", LAND = "Land", FALL = "Fall"}
var CUR_AnimState = AnimStates.RESET

enum MoveStates {LEFT,RIGHT,SLIDE,STOPED}
var CUR_MoveState = MoveStates.STOPED

enum GroundStates {ONGROUND,JUST_FELL,FALL,JUMP,JUST_JUMP,LAND}
var CUR_GroundState = GroundStates.ONGROUND


func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	GunAnimState = $GunAnimTree.get("parameters/playback")
	walkSpeedmax = walkSpeed
func _physics_process(delta):
	if launched:
		walkSpeed = airSpeed+abs(launchVec.x)
	else:
		walkSpeed = walkSpeedmax

	if not is_on_floor():
		velocity.y += gravity * delta
		if coyoteTimer >= coyoteTimerMax:
			canJump = false
			coyoteTimer = coyoteTimerMax
		else:
			coyoteTimer += 1
	else:
		launched = false
		coyoteTimer = 0
		canJump = true

	$Marker2d.look_at(get_global_mouse_position())
	var dev = [GroundStates.keys()[CUR_GroundState],MoveStates.keys()[CUR_MoveState],walkSpeed,velocity,"Launched",launched,CUR_AnimState]
	DEV_GUI(dev)
	GUI.ammo = ammo
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
			if launched and round(launchVec.x) > 0:
				#Checks if the player has been launched by a rocket launcher and if its going the oposite way
				#then setting launched to false which resets the walkspeed
				launched = false
			
			$Sprite2d.flip_h = true
			velocity.x = lerp(velocity.x,-walkSpeed,0.1)
			
		MoveStates.RIGHT:
			if launched and round(launchVec.x) < 0:
				#Same thing as Left but in an oposite direction 
				launched = false
			$Sprite2d.flip_h = false
			velocity.x = lerp(velocity.x,walkSpeed,0.1)
			
		MoveStates.SLIDE:
			if not is_on_floor():
				#Checks if it isnt on the floor to alow for acurate rocket arches
				CUR_MoveState = MoveStates.STOPED
				return
			velocity.x = lerp(velocity.x,0.0,0.5)
	
	match CUR_GroundState:
		
		#A single fire state used to apply the jump foce which makes the player jump
		GroundStates.JUST_JUMP:
			velocity.y = -jumpForce
			CUR_GroundState = GroundStates.JUMP
			CUR_AnimState = AnimStates.JUMP
			ReloadTimer.stop()
			
		GroundStates.FALL:
			CUR_AnimState = AnimStates.FALL
			ReloadTimer.stop()
		
		#Handles if the player has landed just touched the ground
		GroundStates.FALL or GroundStates.JUMP:
			if is_on_floor():
				CUR_GroundState = GroundStates.LAND
			ReloadTimer.stop()
		
		#A single fire state used to trigger reloading and restarting the coyote timer 
		GroundStates.LAND:
			CUR_GroundState = GroundStates.ONGROUND
			ReloadTimer.start()
			canJump = true
			CUR_AnimState = AnimStates.LAND
			
		#groundstate for handling fall detection and onground animations
		GroundStates.ONGROUND:
			canJump = true
			if not is_on_floor():
				CUR_GroundState = GroundStates.FALL
			launched = false
			if CUR_MoveState != MoveStates.STOPED:
				CUR_AnimState = AnimStates.WALK
			else:
				CUR_AnimState = AnimStates.RESET

	BodyAnimState.travel(CUR_AnimState)

#Input Handling and some otherchecks to trigger states
func _stateChecks() -> void:
	
	if Input.is_action_just_pressed("Jump") and canJump:
		CUR_GroundState = GroundStates.JUST_JUMP
	
	if Input.is_action_just_pressed("Shoot") and canShoot:
		shoot()
		
	if Input.is_action_pressed("MoveLeft"):
		CUR_MoveState = MoveStates.LEFT
		
	elif Input.is_action_pressed("MoveRight"):
		CUR_MoveState = MoveStates.RIGHT
		
	elif is_on_floor():
		if round(abs(velocity.x)) == 0:
			CUR_MoveState = MoveStates.STOPED
		else:
			CUR_MoveState = MoveStates.SLIDE

#Handles ammo and rocket spawning 
func shoot() -> void:
	if ammo <= 0 or not canShoot:
		return
	ammo -= 1
	GunAnim.play("Shoot")
	#Spawns a rocket that then has its colision box, icon, and direction rotated to where the player is pointing
	var rocketInstance = rocket.instantiate()
	rocketInstance.moveDirection = Vector2.from_angle($Marker2d.rotation)
	rocketInstance.find_child("Icon").rotation = $Marker2d.rotation
	rocketInstance.find_child("CollisionShape2d").rotation = $Marker2d.rotation
	rocketInstance.position = $Marker2d/Hand.global_position
	get_parent().add_child(rocketInstance)


func _on_gun_anim_animation_started(anim_name):
	canShoot = false

func _on_gun_anim_animation_finished(anim_name):
	canShoot = true
	
func _on_reload_timer_timeout():
	if ammo >= maxAmmo:
		ReloadTimer.stop()
		return
	ammo += 1

#Array parsing used for the Debug user interface
func DEV_GUI(varArr ):
	var outString = ""
	for i in varArr:
		outString += str(i) + "\n"
	GUI.groundstate = outString
