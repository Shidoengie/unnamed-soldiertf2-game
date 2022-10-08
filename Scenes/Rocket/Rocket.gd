extends Area2D

@export var speed = 2500
var velocity = Vector2.ZERO
var dir
@export var damage = 10
func _physics_process(delta):
	position += speed * dir * delta
func _on_rocket_body_entered(body):
	if body.name != "Player":
		$AnimationPlayer.play("Explosion")
		speed = Vector2.ZERO


func _on_animation_player_animation_finished(anim_name):
	queue_free()


func _on_explosion_rad_body_entered(body):
	var bodyDir = Vector2.from_angle(position.angle_to_point(body.position))*Vector2(3000,2000)
	print(bodyDir)
	if body is CharacterBody2D:
		if body.name == "Player":
			var feet = body.find_child("Feet")
			bodyDir += Vector2.from_angle(
				position.angle_to_point(feet.global_position)
				)*Vector2(4,1)*body.walkSpeedmax
		body.velocity = bodyDir
		#Vector2.from_angle(position.angle_to_point(body.position))
	elif body is RigidBody2D:
		pass
