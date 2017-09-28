extends Node

export var tex_path = "res://Art/map.png"
export var count = Vector2(2,2)
export var tile_size = Vector2(8,8)
export var save_path = "res://tl.tres"

var config = {	"%texture_path" : tex_path,
				"%idx" : 0,
				"%name" : "name",
				"%x" : 0,
				"%y" : 0
				}

var start_text = [	"[gd_resource type=\"TileSet\" load_steps=3 format=2]\n",
					"[ext_resource path=\"%texture_path\" type=\"Texture\" id=1]\n",
					"[sub_resource type=\"RectangleShape2D\" id=1]\n",
					"custom_solver_bias = 0.0",
					"extents = Vector2( 16, 16 )\n",
					"[resource]\n"
					]

var tile_text = []

func _ready():
	tile_text = [	"%idx/name = \"%name\"",
					"%idx/texture = ExtResource( 1 )",
					"%idx/tex_offset = Vector2( 0, 0 )",
					"%idx/modulate = Color( 1, 1, 1, 1 )",
					"%idx/region = Rect2( %x, %y, " + str(tile_size.x) + ", " + str(tile_size.y) + " )",
					"%idx/occluder_offset = Vector2( " + str(tile_size.x/2) + ", " + str(tile_size.y/2) + " )",
					"%idx/navigation_offset = Vector2( " + str(tile_size.x/2) + ", " + str(tile_size.y/2) + " )",
					"%idx/shapes = [ {",
					"\"one_way\": false,",
					"\"shape\": SubResource( 1 ),",
					"\"shape_transform\": Transform2D( 1, 0, 0, 1, " + str(tile_size.x/2) + ", " + str(tile_size.y/2) + " )",
					"} ]"
					]
	var file = File.new()
	file.open(save_path, file.WRITE)
	for line in start_text:
		file.store_string(repl (line) + '\n')
	
	var idx = 0
	for j in range (0, count.y):
		for i in range (0, count.x):
			config["%x"] = i * tile_size.x
			config["%y"] = j * tile_size.y
			config["%name"] = "tile_%s-%s" % [i, j]
			config["%idx"] = idx
			for line in tile_text:
				file.store_string(repl (line) + '\n')
			idx += 1
	file.close()
	get_tree().quit()

func repl(lin):
	for wa in config.keys():
		lin = lin.replacen(wa, config[wa])
	return lin