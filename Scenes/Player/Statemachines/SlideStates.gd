extends Node2D

enum {LAUNCHED,ONAIR,ONGROUND,CROUCH}
var current = ONGROUND
const names = ["LAUNCHED","ONAIR","ONGROUND","CROUCH"]
var current_name = "ONGROUND"
func stateMachine(player):
	current_name = names[int(current)]
	match current:
		ONGROUND:
			Global.player.velocity.x = lerp(Global.player.velocity.x,0.0,0.5)
		ONAIR:
			Global.player.velocity.x = lerp(Global.player.velocity.x,0.0,0.1)
		CROUCH:
			Global.player.velocity.x = lerp(Global.player.velocity.x,0.0,0.5)
