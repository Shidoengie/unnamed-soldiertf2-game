extends CharacterBody2D
var BodyAnimState
var GunAnimState
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GunAnim = $GunAnim as AnimationPlayer
@onready var GUI = get_parent().find_child("GUI")
@onready var bullet = preload("res://Scenes/Rocket/Rocket.tscn")
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jumpForce = 300
@export var walkSpeed = 400.0

var isMoving = false
var jumping = false
var walkSpeedmax
var ammo = 3
var airSpeed = 50.0
var launchVec = Vector2.ZERO
var launched = false
var canShoot = true

enum {STOPED = 0,FALLING = 1,WALKING = 2, JUMP = 3}
var anim_dict = {
	0:"RESET",
	1:"Fall",
	2:"Walk",
	3:"Jump"
}
var state
func _ready():
	BodyAnimState = BodyAnimTree.get("parameters/playback")
	GunAnimState = $GunAnimTree.get("parameters/playback")
	walkSpeedmax = walkSpeed
func _physics_process(delta):
	ammo = clamp(ammo,0,3)
	$Marker2d.look_at(get_global_mouse_position())
	if not is_on_floor():
		if launched:
			walkSpeed = airSpeed+abs(launchVec.x)
		velocity.y += gravity * delta
		if jumping:
			state = JUMP
		else:
			state = FALLING
	else:
		if isMoving:
			state = WALKING
			walkSpeed = walkSpeedmax
		if state == FALLING or not isMoving:
			state = STOPED
		launched = false
		jumping = false
	playerControl()
	BodyAnimState.travel(anim_dict[state])
	GUI.states = state
	GUI.walkspeed = walkSpeed
	GUI.vel = velocity
	GUI.lauched = launched
	move_and_slide()

func playerControl() -> void:
	if Input.is_action_just_pressed("Shoot") and canShoot:
		shoot()
	if Input.is_action_pressed("MoveLeft"):
		if velocity.x > 0:
			walkSpeed = walkSpeedmax
			launched = false
		velocity.x = lerp(velocity.x,-walkSpeed,0.1)
		$Sprite2d.flip_h = true
		isMoving = true
	elif Input.is_action_pressed("MoveRight"):
		if velocity.x < 0:
			walkSpeed = walkSpeedmax
			launched = false
		velocity.x = lerp(velocity.x,walkSpeed,0.1)
		$Sprite2d.flip_h = false
		isMoving = true
	elif is_on_floor():
		isMoving = false
		velocity.x = lerp(velocity.x,0.0,0.3)
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		jumping = true
		velocity.y = -jumpForce
func shoot() -> void:
	ammo -= 1
	GunAnim.play("Shoot")
	var bulletInstance = bullet.instantiate()
	bulletInstance.moveDirection = Vector2.from_angle($Marker2d.rotation)
	bulletInstance.find_child("Icon").rotation = $Marker2d.rotation
	bulletInstance.find_child("CollisionShape2d").rotation = $Marker2d.rotation
	bulletInstance.position = $Marker2d/Hand.global_position
	get_parent().add_child(bulletInstance)
