extends CharacterBody2D

var BodyAnimState
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GUI = get_parent().find_child("GUI")
@export var jumpForce = -400.0
@onready var bullet = preload("res://Scenes/Rocket/Rocket.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var isMoving = false
@export var walkSpeed = 400.0
var walkSpeedmax
var airSpeed = 150.0
enum {STOPED = 0,FALLING = 1,WALKING = 2}
var anim_dict = {
	0:"RESET",
	1:"Fall",
	2:"Walk",
}
var state
func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	walkSpeedmax = walkSpeed
func _physics_process(delta):
	$Marker2d.look_at(get_global_mouse_position())
	if not is_on_floor():
		walkSpeed = airSpeed
		velocity.y += gravity * delta
		state = FALLING
	elif isMoving:
		state = WALKING
		walkSpeed = walkSpeedmax
	elif not isMoving or state == FALLING:
		state = STOPED
		walkSpeed = walkSpeedmax
	if Input.is_action_just_pressed("Shoot"):
		var bulletInstance = bullet.instantiate()
		bulletInstance.moveDirection = Vector2.from_angle($Marker2d.rotation)
		bulletInstance.find_child("Icon").rotation = $Marker2d.rotation
		bulletInstance.find_child("CollisionShape2d").rotation = $Marker2d.rotation
		bulletInstance.position = global_position
		get_parent().add_child(bulletInstance)

	if Input.is_action_pressed("MoveLeft"):
		velocity.x = lerp(velocity.x,-walkSpeed,0.1)
		$Sprite2d.flip_h = true
		isMoving = true
	elif Input.is_action_pressed("MoveRight"):
		velocity.x = lerp(velocity.x,walkSpeed,0.1)
		$Sprite2d.flip_h = false
		isMoving = true
	elif is_on_floor():
		isMoving = false
		velocity.x = lerp(velocity.x,0.0,0.3)
		
	BodyAnimState.travel(anim_dict[state])
	GUI.states = state
	GUI.walkspeed = walkSpeed
	GUI.vel = velocity
	move_and_slide()

