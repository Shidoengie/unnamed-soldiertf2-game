extends CanvasLayer

var groundstate = ""
var ammo
func _process(delta):
	$DEV/Label6.text = groundstate
	$Ammo.text = str(ammo)

func _ready():
	Global.DevGUI = self
