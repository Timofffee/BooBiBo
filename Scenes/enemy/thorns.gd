extends Node2D

var thorn = preload ("res://Scenes/enemy/thorns_flying.tscn")

export (float, 0, 3.0) var timestart = 0

func _ready():
	$'anim'.seek(timestart, true)

func spawn():
	var t = thorn.instance()
	add_child(t)
	t.position = $'spawn_pos'.position
