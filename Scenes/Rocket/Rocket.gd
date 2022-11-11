extends Area2D

@export var explosionForce = 400
@export var speed = 2500
var velocity = Vector2.ZERO
var moveDirection
@export var damage = 10
func _physics_process(delta):
	position += speed * moveDirection * delta
func _on_rocket_body_entered(body):
	if body.name != "Player":
		$AnimationPlayer.play("Explosion")
		speed = Vector2.ZERO


func _on_animation_player_animation_finished(anim_name):
	queue_free()
func _on_explosion_rad_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player":
		body.velocity = -moveDirection * explosionForce
		body.launchVec = -moveDirection * explosionForce
		pass
	elif body is RigidBody2D:
		pass


func _on_explosion_rad_body_shape_exited(body_rid, body, body_shape_index, local_shape_index):
	if body.name == "Player":
		body.launched = true
