extends Area2D

func _on_thorns_flying_body_entered(body):
	if body.has_method("damage"):
		body.damage(1, self)
