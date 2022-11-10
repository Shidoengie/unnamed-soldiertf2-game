extends CanvasLayer

var groundstate = ""
var movestate = ""
var walkspeed = 0
var vel = 0
var lauched = false
var canjump = false
var ammo = 0

func _process(delta):
	$DEV/Label.text = groundstate
	$DEV/Label6.text = movestate 
	$DEV/Label2.text = str(vel)
	$DEV/Label3.text = str(walkspeed)
	$DEV/Label4.text = "lauched "+str(lauched)
	$Ammo.text = str(ammo)
	$DEV/Label5.text = str(canjump)
