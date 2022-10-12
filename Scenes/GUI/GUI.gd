extends CanvasLayer

var states = 0
var walkspeed = 0
var vel = 0
var lauched = false
var ammo = 0
var state_names = {
	0:"STOPPED",
	1:"FALLING",
	2:"WALKING",
}
func _process(delta):
	$DEV/Label.text = state_names[states]
	$DEV/Label2.text = str(vel)
	$DEV/Label3.text = str(walkspeed)
	$DEV/Label4.text = "lauched "+str(lauched)
	$Ammo.text = str(ammo)
