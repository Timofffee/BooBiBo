extends Control

export var zone_text = ""
export var location = "Unknow"
var health_step = 4
var STATE = 0
var die_button = -1
enum {STATE_INGAME, STATE_PAUSE, STATE_DIE_BUTTONS, STATE_CHANGE_SCENE}

func _process(delta):
	if STATE == STATE_DIE_BUTTONS:
		if Input.is_action_just_pressed("jump_1"):
			die_button = 0
			STATE = STATE_CHANGE_SCENE
		elif Input.is_action_just_pressed("shoot_1"):
			die_button = 1
			STATE = STATE_CHANGE_SCENE
	elif STATE == STATE_CHANGE_SCENE:
		$'game_over/anim'.play("do")
		set_process(false)

func _ready():
	$'change_scene/zone'.text = zone_text
	$'change_scene/loc'.text = location
#	update_health()

func update_health():
	var players = get_tree().get_nodes_in_group("player")
	$'hud/health/1/under'.rect_size.x = players[0].health_max * health_step
	$'hud/health/1/line'.rect_size.x = players[0].health * health_step

func _on_checker_timeout():
	var players = get_tree().get_nodes_in_group("player")
	if players.size() <= 0:
		$'game_over/anim'.play("game_over")
		$'checker'.stop()

func die_menu_end():
	if die_button == 0:
		get_tree().change_scene("res://Scenes/polygone.tscn")
	elif die_button == 1:
		get_tree().quit()

func die_menu_buttons():
	STATE = STATE_DIE_BUTTONS
	set_process(true)