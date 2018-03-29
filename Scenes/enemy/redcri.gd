extends KinematicBody2D

const GRAVITY_VEC = Vector2(0,900)
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_SLIDE_STOP = 10.0
const MIN_ONAIR_TIME = 0.1
const WALK_SPEED = 100 # pixels/sec
const SIDING_CHANGE_SPEED = 10
const JUMP_SPEED = 180

var linear_vel = Vector2()
var onair_time = 0 #
var on_floor = false

var anim=''

var dir = 0
var health = 3
var damage = false
var on_screen = true

onready var sprite = $'body'
onready var ray_r = $'check_floor_r'
onready var ray_l = $'check_floor_l'
onready var check_wall_l = $'check_wall_l'
onready var check_wall_r = $'check_wall_r'
onready var check_jump_l = $'check_jump_l'
onready var check_jump_r = $'check_jump_r'

func _physics_process(delta):
	#increment counters

	onair_time+=delta


	linear_vel += delta * GRAVITY_VEC
	linear_vel = move_and_slide( linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP )
	if (is_on_floor()):
		onair_time=0

	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###
#	linear_vel.y=-JUMP_SPEED
	var can_jump = false
	if dir == -1 and not check_jump_l.is_colliding():
		can_jump = true
	elif dir == 1 and not check_jump_r.is_colliding():
		can_jump = true
	# Horizontal Movement
	var target_speed = 0
	if not check_wall_l.is_colliding():
		if (ray_l.is_colliding() and dir == -1):
			target_speed += -1
	elif can_jump and dir == -1:
		linear_vel.y=-JUMP_SPEED
		target_speed += -1
	if not check_wall_r.is_colliding():
		if (ray_r.is_colliding() and dir == 1):
			target_speed +=  1
	elif can_jump and dir == 1:
		linear_vel.y=-JUMP_SPEED
		target_speed +=  1
	if damage:
		damage = false
		target_speed -= dir*5
		linear_vel.y=-JUMP_SPEED
	target_speed *= WALK_SPEED
	linear_vel.x = lerp( linear_vel.x, target_speed, 0.5 )

	### ANIMATION ###

	var new_anim='idle'

	if on_floor:
		if anim == 'falling':
				new_anim = 'bounce'
		else:
			if (linear_vel.x < -SIDING_CHANGE_SPEED):
				sprite.scale.x = -1
				new_anim='run'
	
			if (linear_vel.x > SIDING_CHANGE_SPEED):
				sprite.scale.x = 1
				new_anim='run'
	else:
		if (linear_vel.y < 0 ):
				new_anim='jumping'
		else:
			new_anim='falling'
	
	if (new_anim!=anim):
		if $'anim'.get_current_animation() in ['bounce', 'damage']:
			pass
		else:
			anim=new_anim
			$'anim'.play(anim)

func die():
	$'kill_zone/col'.disabled = true
	$'part'.emitting = false
	$'anim'.play('die')
	set_physics_process(false)

func die_clear():
	
	$'update_target_dir'.queue_free()
	$'col'.queue_free()
	$'body'.queue_free()

func damage(val):
	health -= val
	damage = true
	$'anim'.play('damage')
	if health <= 0:
		die()

func _update_dir ():
	var players = get_tree().get_nodes_in_group('player')
	var player_pos = Vector2()
	var dist_p = 9999
	for p in players:
		if position.distance_to(p.position) < dist_p:
			dist_p = position.distance_to(p.position)
			player_pos = p.position
	
	var new_dir = Vector2(player_pos.x - position.x, 0).normalized().x
	dir = new_dir



func _on_visib_screen_entered():
	if on_screen:
		$'shower'.start()
		on_screen = false

func _on_visib_screen_exited():
	if not on_screen:
		$'shower'.start()
		on_screen = true

func _ready():
	_on_shower_timeout()

func _on_shower_timeout():
	if on_screen:
		if has_node('update_target_dir'):
			$'update_target_dir'.stop()
		if has_node("body"):
			$'body'.visible = false
		if has_node("col"):
			$'col'.disabled = true
		$'anim'.stop()
		$'part'.emitting = false
		set_physics_process(false)
		$'kill_zone/col'.disabled = true
	elif not on_screen and $'body'.visible == false:
		$'update_target_dir'.start()
		$'body'.visible = true
		$'col'.disabled = false
		$'effects'.play('poof')
		$'anim'.play('idle')
		$'part'.emitting = true
		set_physics_process(true)
		$'kill_zone/col'.disabled = false

func _on_kill_zone_body_entered( body ):
	if body.has_method('damage'):
		body.damage(1, self)
