extends CharacterBody2D


var BodyAnimState : AnimationNodeStateMachinePlayback
var GunAnimState : AnimationNodeStateMachinePlayback
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GunAnim = $GunAnim as AnimationPlayer
@onready var GUI = get_parent().find_child("GUI")
@onready var bullet = preload("res://Scenes/Rocket/Rocket.tscn")
@onready var ReloadTimer = $ReloadTimer as Timer

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jumpForce = 300
@export var walkSpeed = 400.0

var walkSpeedmax
var ammo = 3
var launched = false
var launchVec : Vector2
var canShoot = true
var maxAmmo = 3
var canJump = true

@export var coyoteTimer_max = 5
var coyoteTimer = 0

const AnimStates = {  RESET = "RESET", WALK = "Walk", JUMP = "Jump", LAND = "Land", FALL = "Fall"}
var CUR_AnimState = ""
enum MoveStates {LEFT,RIGHT,SLIDE,STOPED}
var CUR_MoveState = 0
enum GroundStates {JUST_FELL,FALL,JUMP,JUST_JUMP,LAND,ONGROUND}
var CUR_GroundState = 0
var state = 0
var animState = 0

func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	GunAnimState = $GunAnimTree.get("parameters/playback")
	walkSpeedmax = walkSpeed
func _physics_process(delta):
	if not is_on_floor():
		velocity.y += gravity * delta
		if coyoteTimer >= coyoteTimer_max:
			canJump = false
			coyoteTimer = coyoteTimer_max
		else:
			coyoteTimer += 1
	else:
		coyoteTimer = 0
		canJump = true
	$Marker2d.look_at(get_global_mouse_position())
	
	GUI.groundstate = GroundStates.keys()[CUR_GroundState]
	GUI.movestate = MoveStates.keys()[CUR_MoveState]
	GUI.walkspeed = walkSpeed
	GUI.vel = coyoteTimer
	GUI.lauched = launched
	GUI.ammo = ammo
	GUI.canjump = CUR_AnimState
	_stateChecks()
	_stateMachines(delta)
	move_and_slide()
func _stateMachines(delta) -> void:
	if (CUR_GroundState == GroundStates.FALL or CUR_GroundState == GroundStates.JUMP) and is_on_floor():
		CUR_GroundState = GroundStates.LAND
	
	match CUR_MoveState:
		
		MoveStates.LEFT:
			$Sprite2d.flip_h = true
			if launched:
				velocity.x = lerp(velocity.x,-walkSpeed + launchVec.x,0.1) 
			velocity.x = lerp(velocity.x,-walkSpeed,0.1)
			
		MoveStates.RIGHT:
			$Sprite2d.flip_h = false
			if launched:
				velocity.x = lerp(velocity.x,walkSpeed + launchVec.x,0.1)
			velocity.x = lerp(velocity.x,walkSpeed,0.1)
			
		MoveStates.SLIDE:
			velocity.x = lerp(velocity.x,0.0,0.5)
		
	match CUR_GroundState:
		
		GroundStates.JUST_JUMP:
			velocity.y = -jumpForce
			CUR_GroundState = GroundStates.JUMP
			CUR_AnimState = AnimStates.JUMP
			ReloadTimer.stop()
			
		GroundStates.FALL:
			CUR_AnimState = AnimStates.FALL
			ReloadTimer.stop()
			
			
		GroundStates.FALL or GroundStates.JUMP:
			if is_on_floor():
				CUR_GroundState = GroundStates.LAND
			ReloadTimer.stop()
		
		GroundStates.LAND:
			CUR_GroundState = GroundStates.ONGROUND
			ReloadTimer.start()
			canJump = true
			CUR_AnimState = AnimStates.LAND
			
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
			return
		CUR_MoveState = MoveStates.SLIDE
	
func shoot() -> void:
	if ammo <= 0 or not canShoot:
		return
		
	ammo -= 1
	GunAnim.play("Shoot")
	var bulletInstance = bullet.instantiate()
	bulletInstance.moveDirection = Vector2.from_angle($Marker2d.rotation)
	bulletInstance.find_child("Icon").rotation = $Marker2d.rotation
	bulletInstance.find_child("CollisionShape2d").rotation = $Marker2d.rotation
	bulletInstance.position = $Marker2d/Hand.global_position
	get_parent().add_child(bulletInstance)


func _on_gun_anim_animation_started(anim_name):
	canShoot = false

func _on_gun_anim_animation_finished(anim_name):
	canShoot = true
func _on_reload_timer_timeout():
	if ammo >= maxAmmo:
		ReloadTimer.stop()
		return
	ammo += 1
