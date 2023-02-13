extends Node
@onready var AnimStates = %AnimStates
@onready var SpeedValues = %SpeedValues
@onready var SlideStates = %SlideStates
@onready var MoveStates = %MoveStates
@onready var GroundStates = %GroundStates
enum{
	LEFT, RIGHT,
	SLIDE, STOPED
}
var current = STOPED
const names = [
	"LEFT", "RIGHT",
	"SLIDE", "STOPED"
]
var current_name
func stateMachine(player:CharacterBody2D):
	current_name = names[int(current)]
	#Statemachine for handling horizontal movement along with interpolation for smooth movement
	match current:
		LEFT:
			if SlideStates.current == SlideStates.LAUNCHED and round(player.launchVec.x) > 0:
				#Checks if the player has been launched by an explosion and if its going the oposite way
				#then setting launched to false which resets the moveSpeed
				SlideStates.current = SlideStates.ONGROUND

			%Sprite2d.flip_h = true
			Global.playerVelocity.x = lerp(Global.playerVelocity.x,float(-player.moveSpeed),0.1)

		RIGHT:
			if SlideStates.current == SlideStates.LAUNCHED and round(player.launchVec.x) < 0:
				#Same thing as Left but in an oposite direction
				SlideStates.current = SlideStates.ONGROUND
			%Sprite2d.flip_h = false
			Global.playerVelocity.x = lerp(Global.playerVelocity.x,float(player.moveSpeed),0.1)

		SLIDE:
			_SlideState(player)

func _SlideState(player:CharacterBody2D):
	if not player.is_on_floor() and SlideStates.current == SlideStates.LAUNCHED:
		#Checks if it isnt on the floor to alow for acurate rocket arches
		current = STOPED
		return
	SlideStates.stateMachine(player)
