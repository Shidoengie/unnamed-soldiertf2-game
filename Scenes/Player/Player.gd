extends CharacterBody2D

var BodyAnimState
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GUI = get_parent().find_child("GUI")
@export var jumpForce = -400.0
@onready var bullet = preload("res://Scenes/Rocket/Rocket.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var jumped = false
var canMove = false
var isMoving = false
@export var walkSpeed = 400.0
var walkSpeedmax
var endSpeed = 0.0

enum {JUMPING = 0,STOPED = 1,FALLING = 2,WALKING = 3}
var anim_dict = {
	0:"Jump",
	1:"RESET",
	2:"Fall",
	3:"Walk",
}
var state
func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	walkSpeedmax = walkSpeed
func _physics_process(delta):
	$Marker2d.look_at(get_global_mouse_position())
	
	if not is_on_floor():
		canMove = true
		velocity.y += gravity * delta
		if jumped:
			state = JUMPING
		else:
			state = FALLING
	else:
		if state == JUMPING or state == FALLING:
			state = STOPED
		jumped = false
		
	if Input.is_action_just_pressed("Shoot"):
		var bulletInstance = bullet.instantiate()
		print(Vector2.from_angle($Marker2d.rotation))
		bulletInstance.dir = Vector2.from_angle($Marker2d.rotation)
		bulletInstance.find_child("Icon").rotation = $Marker2d.rotation
		bulletInstance.find_child("CollisionShape2d").rotation = $Marker2d.rotation
		bulletInstance.position = global_position
		get_parent().add_child(bulletInstance)
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jumpForce
		jumped = true
	if state == JUMPING or state == FALLING:
		walkSpeed = max(lerp(walkSpeed,walkSpeedmax/2.5,0.01),walkSpeedmax/2.5)
	else:
		walkSpeed = walkSpeedmax
	if Input.is_action_pressed("MoveLeft"):
		velocity.x = -walkSpeed
		$Sprite2d.flip_h = true
		isMoving = true
	elif Input.is_action_pressed("MoveRight"):
		velocity.x = walkSpeed
		$Sprite2d.flip_h = false
		isMoving = true
	elif canMove:
		isMoving = false
		velocity.x = lerp(velocity.x,0.0,0.3)
	if isMoving and is_on_floor():
		state = WALKING
	elif not isMoving and is_on_floor():
		state = STOPED
	BodyAnimState.travel(anim_dict[state])
	GUI.states = state
	GUI.walkspeed = walkSpeed
	GUI.vel = velocity
	move_and_slide()

