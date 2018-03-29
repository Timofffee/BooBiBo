extends Area2D

export (float, 0, 3.0) var timestart = 0

func _ready():
	$'anim'.seek(timestart, true)

func _on_thorns_flying_body_entered(body):
	if body.has_method("damage"):
		body.damage(1, self)