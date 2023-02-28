extends Node2D
@onready var player = %PlayerBody
enum {LAUNCHED,ONAIR,ONGROUND,CROUCH}
var current = ONGROUND
const names = ["LAUNCHED","ONAIR","ONGROUND","CROUCH"]
var current_name = "ONGROUND"
func stateMachine(player):
	current_name = names[int(current)]
	match current:
		ONGROUND:
			player.velocity.x = lerp(player.velocity.x,0.0,0.5)
		ONAIR:
			player.velocity.x = lerp(player.velocity.x,0.0,0.1)
		CROUCH:
			player.velocity.x = lerp(player.velocity.x,0.0,0.5)
