extends RigidBody2D

var BodyAnimplayerState
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GUI = get_parent().find_child("GUI")
@export var jumpForce = -400.0
@onready var bullet = preload("res://Scenes/Rocket/Rocket.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


var jumped = false
var canMove = false
var isMoving = false
var isOnfloor
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
var playerState
func _ready():
	BodyAnimplayerState = BodyAnimTree.get("parameters/playback")
	walkSpeedmax = walkSpeed
func _integrate_forces(s):
	var colArr = [$RayCast2d.is_colliding(),$RayCast2d2.is_colliding(),$RayCast2d3.is_colliding()]
	isOnfloor = get_contact_count()>0
	$Marker2d.look_at(get_global_mouse_position())
	
	if get_contact_count() == 0:
		canMove = true
		if jumped:
			playerState = JUMPING
		else:
			playerState = FALLING
	else:
		if playerState == JUMPING or playerState == FALLING:
			playerState = STOPED
		jumped = false
		
	if Input.is_action_just_pressed("Shoot"):
		shoot()
	if Input.is_action_just_pressed("Jump") and isOnfloor:
		s.linear_velocity.y = jumpForce
		jumped = true
	if playerState == JUMPING or playerState == FALLING:
		walkSpeed = max(lerp(walkSpeed,walkSpeedmax/2.5,0.01),walkSpeedmax/2.5)
	else:
		walkSpeed = walkSpeedmax
	if Input.is_action_pressed("MoveLeft"):
		s.linear_velocity.x = -walkSpeed
		$Sprite2d.flip_h = true
		isMoving = true
	elif Input.is_action_pressed("MoveRight"):
		s.linear_velocity.x = walkSpeed
		$Sprite2d.flip_h = false
		isMoving = true
	elif canMove:
		isMoving = false
		s.linear_velocity.x = lerp(s.linear_velocity.x,0.0,0.3)
	if isMoving and isOnfloor:
		playerState = WALKING
	elif not isMoving and isOnfloor:
		playerState = STOPED
	
	BodyAnimplayerState.travel(anim_dict[playerState])
	GUI.states = playerState
	GUI.walkspeed = walkSpeed
	GUI.vel = s.linear_velocity

func shoot():
	var bulletInstance = bullet.instantiate()
	bulletInstance.dir = Vector2.from_angle($Marker2d.rotation)
	bulletInstance.find_child("Icon").rotation = $Marker2d.rotation
	bulletInstance.find_child("CollisionShape2d").rotation = $Marker2d.rotation
	bulletInstance.position = global_position
	get_parent().add_child(bulletInstance)
