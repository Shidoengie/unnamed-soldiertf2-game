extends Node2D
# Called every frame. 'delta' is the elapsed time since the previous frame.
@onready var AnimStates = %AnimStates
@onready var SpeedValues = %SpeedValues
@onready var SlideStates = %SlideStates
@onready var MoveStates = %MoveStates
@onready var GroundStates = %GroundStates
@onready var camera = %Camera2d
@onready var player_body = %PlayerBody
@onready var player_visible = %PlayerVisible
@onready var camera_offset = camera.global_transform.origin
@onready var Base_CameraPos = camera.global_transform.origin
var falling = false
@onready var CameraValues = {
	CROUCH = Vector2(0,100) + Base_CameraPos,
	LOOK_DOWN = Vector2(0,100) + Base_CameraPos, LOOK_UP = Vector2(0,-70) + Base_CameraPos,
}
func _process(delta):
	if Input.is_action_pressed("look_down"):
		camera_offset = CameraValues.LOOK_DOWN
	elif Input.is_action_pressed("look_up"):
		camera_offset = CameraValues.LOOK_UP
	elif GroundStates.current == GroundStates.CROUCH:
		camera_offset = CameraValues.CROUCH
	elif player_visible.is_on_screen() and GroundStates.current != GroundStates.FALL:
		camera_offset = Base_CameraPos
	
	camera.global_transform.origin.x = player_body.position.x+camera_offset.x
	if player_body.is_on_floor():
		falling = false
	if falling:
		camera.global_transform.origin.y = player_body.global_transform.origin.y+150
	elif GroundStates.current != GroundStates.JUMP or (Input.is_action_just_released("look_down") or Input.is_action_just_released("look_up")):
		camera.global_transform.origin.y = player_body.position.y+camera_offset.y
	
	

func _on_player_visible_screen_exited():
	if GroundStates.current == GroundStates.FALL:
		falling = true
