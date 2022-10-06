extends Area2D

@export var speed = 2500
var velocity = Vector2.ZERO
var dir
@export var damage = 10
func _ready():
	dir = transform.x
	
func _physics_process(delta):
	position += dir * speed * delta
func _on_rocket_body_entered(body):
#	if body.name == "Player":
#		body.take_dmg(damage)
#		body.health_changed = true
#		queue_free()
#		return
	queue_free()
