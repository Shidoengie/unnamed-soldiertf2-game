extends Node2D
@onready var AnimStates = %AnimStates
@onready var SpeedValues = %SpeedValues
@onready var SlideStates = %SlideStates
@onready var MoveStates = %MoveStates
@onready var GroundStates = %GroundStates
enum {
	ONGROUND, LAND,
	FALL, JUST_FELL,
	JUMP, JUST_JUMP,
	CROUCH, RUN
}
const names = [
	"ONGROUND", "LAND",
	"FALL", "JUST_FELL",
	"JUMP", "JUST_JUMP",
	"CROUCH", "RUN"
]
var current_name
var current = ONGROUND
func stateMachine(player:CharacterBody2D):
	current_name = names[int(current)]
	match current:
		#A single fire state used to apply the jump foce which makes the player jump
		JUST_JUMP:
			Global.playerVelocity.y = -PlayerStats.jumpForce
			current = JUMP
			AnimStates.current = AnimStates.Enum.JUMP

		FALL:
			AnimStates.current = AnimStates.Enum.FALL

		#Handles if the player has landed just touched the ground
		FALL , JUMP:
			if player.is_on_floor():
				current = LAND

		#A single fire state used to trigger reloading and restarting the coyote timer
		LAND:
			current = ONGROUND
			player.canJump = true
			AnimStates.current = AnimStates.LAND

		#groundstate for handling fall detection and onground animations
		ONGROUND: _OngroudState(player)
		CROUCH: _CrouchState(player)
		_:
			pass

func _OngroudState(player):
	player.canJump = true
	if not player.is_on_floor():
		current = FALL
	SpeedValues.current = SpeedValues.WALK
	SlideStates.current = SlideStates.ONGROUND
	if MoveStates.current != MoveStates.STOPED:
		AnimStates.current = AnimStates.Enum.WALK
	else:
		AnimStates.current = AnimStates.Enum.RESET
func _CrouchState(player):
	SlideStates.current = SlideStates.CROUCH
	SpeedValues.current = SpeedValues.CROUCH
	if MoveStates.current != MoveStates.STOPED:
		AnimStates.current = AnimStates.Enum.CROUCH_WALK
	else:
		AnimStates.current = AnimStates.Enum.CROUCH_IDLE
	%Camera2d.position = player.CameraValues.CROUCH
