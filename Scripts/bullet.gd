extends KinematicBody2D

var dir = Vector2(0,0)
var speed = 3
var damage = 1

func _physics_process(delta):
	move_and_collide(dir*speed)

func _on_area_body_entered( body ):
	if body.has_method("damage"):
		body.damage(damage)
	queue_free()
