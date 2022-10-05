extends CharacterBody2D

@onready var AnimPlayer = $AnimPlayer as AnimationPlayer
@onready var ParticlePlayer = $ParticlePlayer as AnimationPlayer

@onready var GUI = get_parent().find_child("GUI")
@export var jumpForce = -400.0
# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")

var anim = "RESET"

var canMove = false
var isntMoving = false
@export var walkSpeed = 300.0
var walkSpeedmax
var endSpeed = 0.0

enum {JUMPING = 0,STOPED = 1,FALLING = 2,WALKING = 3,RUNNING = 4}
var anim_dict = {
	0:"Jump",
	1:"RESET",
	2:"Fall",
	3:"Walk",
	4:"Walk"
}
var state
func _ready():
	walkSpeedmax = walkSpeed
func _physics_process(delta):
	
	isntMoving = round(abs(velocity.x)) == 0
	if not is_on_floor():
		velocity.y += gravity * delta
		if state != JUMPING and state != RUNNING:
			state = FALLING
	else:
		canMove = true
		if state == JUMPING or isntMoving:
			state = STOPED
			endSpeed = walkSpeedmax
		elif state != JUMPING:
			state = WALKING
	
	if Input.is_action_just_pressed("Jump") and is_on_floor():
		velocity.y = jumpForce
		state = JUMPING
	if state == JUMPING or state == FALLING:
		walkSpeed = max(lerp(walkSpeed,walkSpeedmax/2.5,0.01),walkSpeedmax/2.5)
	else:
		walkSpeed = walkSpeedmax
	if Input.is_action_pressed("MoveLeft"):
		velocity.x = -walkSpeed
		$Sprite2d.flip_h = true
	elif Input.is_action_pressed("MoveRight"):
		velocity.x = walkSpeed
		$Sprite2d.flip_h = false
	elif not is_on_floor():
		velocity.x = lerp(velocity.x,0.0,0.1)
	elif canMove:
		velocity.x = lerp(velocity.x,0.0,0.3)
	
	if velocity.floor().abs() == Vector2.RIGHT:
		ParticlePlayer.play("Slide")
	AnimPlayer.play(anim_dict[state])
	GUI.states = state
	GUI.walkspeed = walkSpeed
	GUI.vel = velocity
	move_and_slide()

