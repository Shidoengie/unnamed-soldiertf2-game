extends Node2D
@onready var AnimStates = %AnimStates
@onready var SpeedValues = %SpeedValues
@onready var SlideStates = %SlideStates
@onready var MoveStates = %MoveStates
@onready var GroundStates = %GroundStates
@onready var player = %PlayerBody
@onready var rootNode = $"../../.."
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
func stateMachine():
	current_name = names[int(current)]
	match current:
		#A single fire state used to apply the jump foce which makes the player jump
		JUST_JUMP:
			_JustJumpState()
		FALL:
			AnimStates.current = AnimStates.Enum.FALL
		#Handles if the player has landed just touched the ground
		FALL , JUMP:
			if player.is_on_floor():
				current = LAND

		#A single fire state used to trigger reloading and restarting the coyote timer
		LAND:
			_LandState()
		#groundstate for handling fall detection and onground animations
		ONGROUND: _OngroudState()
		CROUCH: _CrouchState()
		_:
			pass
func _JustJumpState():
	player.velocity.y = -PlayerStats.jumpForce
	current = JUMP
	AnimStates.current = AnimStates.Enum.JUMP
func _LandState():
	current = ONGROUND
	player.canJump = true
	AnimStates.current = AnimStates.Enum.LAND
func _OngroudState():
	player.canJump = true
	if not player.is_on_floor():
		current = FALL
	SpeedValues.current = SpeedValues.WALK
	SlideStates.current = SlideStates.ONGROUND
	if MoveStates.current != MoveStates.STOPED:
		AnimStates.current = AnimStates.Enum.WALK
	else:
		AnimStates.current = AnimStates.Enum.RESET
func _CrouchState():
	SlideStates.current = SlideStates.CROUCH
	SpeedValues.current = SpeedValues.CROUCH
	if MoveStates.current != MoveStates.STOPED:
		AnimStates.current = AnimStates.Enum.CROUCH_WALK
	else:
		AnimStates.current = AnimStates.Enum.CROUCH_IDLE
