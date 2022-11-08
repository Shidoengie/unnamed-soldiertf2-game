extends CharacterBody2D


var BodyAnimState : AnimationNodeStateMachinePlayback
var GunAnimState : AnimationNodeStateMachinePlayback
@onready var BodyAnimTree = $BodyAnimationTree as AnimationTree
@onready var GunAnim = $GunAnim as AnimationPlayer
@onready var GUI = get_parent().find_child("GUI")
@onready var bullet = preload("res://Scenes/Rocket/Rocket.tscn")
@onready var ReloadTimer = $ReloadTimer as Timer
@onready var CoyoteTimer = $CoyoteTimer as Timer
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@export var jumpForce = 300
@export var walkSpeed = 400.0
var walkSpeedmax

var isMoving = false
var jumping = false
var ammo = 3
var airSpeed = 50.0
var launchVec = Vector2.ZERO
var launched = false


var canJump = true

var canShoot = true
var maxAmmo = 3
enum {STOPED = 0,FALLING = 1,WALKING = 2, JUMP = 3}
var anim_dict = {
	0:"RESET",
	1:"Fall",
	2:"Walk",
	3:"Jump"
}
var state

func _PlayerInput():
	if Input.is_action_just_pressed("Jump") and canJump:
		_Jump()
	if Input.is_action_just_pressed("MoveLeft"):
		pass
	elif Input.is_action_just_pressed("MoveRight"):
		pass
func _Jump():
	pass
func _shoot() -> void:
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
	

func _on_reload_timer_timeout():
	if ammo >= maxAmmo:
		ReloadTimer.stop()
		return
	ammo += 1
