extends Area2D

@export var speed = 2500
var velocity = Vector2.ZERO
var dir
@export var damage = 10
func _physics_process(delta):
	position += dir * speed * delta
func _on_rocket_body_entered(body):
	if body.name != "Player":
		print(body.name)
		$AnimationPlayer.play("Explosion")
		dir = Vector2.ZERO


func _on_animation_player_animation_finished(anim_name):
	queue_free()
