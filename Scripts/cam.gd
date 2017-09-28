extends Camera2D

var targets = []
var min_zoom = 1.0

func _process(delta):
	var window_size = OS.get_window_size()/4
	if targets.size() > 0:
		var cam_pos = targets[0].position
		var min_pos = targets[0].position
		var max_pos = targets[0].position
		for tar in targets:
			cam_pos = (cam_pos + tar.position)/2
			
			min_pos.x = min(tar.position.x, min_pos.x)
			min_pos.y = min(tar.position.y, min_pos.y)
			max_pos.x = max(tar.position.x, max_pos.x)
			max_pos.y = max(tar.position.y, max_pos.y)
			
			var dist = max_pos - min_pos
			
			var zoomy = (dist + Vector2(200,100)) / window_size 
			var nzoom = max( min_zoom, max ( zoomy.x, zoomy.y))
			zoom = zoom.linear_interpolate(Vector2(nzoom, nzoom), 0.5)
		position = cam_pos
