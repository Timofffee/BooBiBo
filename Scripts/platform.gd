extends Path2D

var path
var speed = 50
var offset = 0
var forwrd = true
var max_offset
 
func _ready():
	path = get_curve()
	max_offset = path.get_baked_length()

func _process(delta):
	if forwrd:
		offset += delta * speed
		if offset >= max_offset:
			offset = max_offset
			forwrd = false
	else:
		offset -= delta * speed
		if offset <= 0:
			offset = 0
			forwrd = true
	var new_pos = path.interpolate_baked(offset)
	$obj.position = new_pos
	