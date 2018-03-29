extends Area2D

const SPEED = 128
const DIR = Vector2(0, 1)

func _process(delta):
	position += DIR * SPEED * delta

func _on_thorns_flying_body_entered(body):
	if body.has_method("damage"):
		body.damage(1, self)
	queue_free()
