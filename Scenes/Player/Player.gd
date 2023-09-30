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
enum CameraSettings {
	FOLLOW,
	ONGROUND_FOLLOW,
}
@export var cur_CameraSettings = CameraSettings.ONGROUND_FOLLOW
@onready var CameraValues = {
	CROUCH = Vector2(0,100) + Base_CameraPos,
	LOOK_DOWN = Vector2(0,100) + Base_CameraPos,
	LOOK_UP = Vector2(0,-70) + Base_CameraPos,
}
func _process(delta):
	if Input.is_action_pressed("look_down"):
		camera_offset = lerp(camera_offset,CameraValues.LOOK_DOWN,0.15)
	elif Input.is_action_pressed("look_up"):
		camera_offset = lerp(camera_offset,CameraValues.LOOK_UP,0.15)
	elif GroundStates.current == GroundStates.CROUCH:
		camera_offset = lerp(camera_offset,CameraValues.CROUCH,0.15)
	elif player_visible.is_on_screen() and GroundStates.current != GroundStates.FALL:
		camera_offset = lerp(camera_offset,Base_CameraPos,0.15)
	var new_xpos = player_body.position.x+camera_offset.x
	camera.global_transform.origin.x = new_xpos
	match cur_CameraSettings:
		CameraSettings.FOLLOW:
			camera.global_transform.origin.y = player_body.position.y+camera_offset.y
		CameraSettings.ONGROUND_FOLLOW:
			_onground_follow()
func _onground_follow():
	if player_body.is_on_floor():
		falling = false
	if falling:
		camera.global_transform.origin.y = player_body.global_transform.origin.y+150
	elif GroundStates.current != GroundStates.JUMP or (Input.is_action_just_released("look_down") or Input.is_action_just_released("look_up")):
		camera.global_transform.origin.y = player_body.position.y+camera_offset.y
func _on_player_visible_screen_exited():
	if GroundStates.current == GroundStates.FALL:
		falling = true
