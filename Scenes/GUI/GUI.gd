extends CanvasLayer

var states = 0
var walkspeed = 0
var vel = 0
var lauched = false
var state_names = {
	0:"STOPPED",
	1:"FALLING",
	2:"WALKING",
}
func _process(delta):
	$HBoxContainer/Label.text = state_names[states]
	$HBoxContainer/Label2.text = str(vel)
	$HBoxContainer/Label3.text = str(walkspeed)
	$HBoxContainer/Label4.text = "lauched "+str(lauched)
