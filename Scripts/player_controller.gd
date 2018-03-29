extends KinematicBody2D

const GRAVITY_VEC = Vector2(0,900)
const LOW_GRAVITY_VEC = Vector2(0,50)
const FLOOR_NORMAL = Vector2(0,-1)
const SLOPE_SLIDE_STOP = 15.0
const MIN_ONAIR_TIME = 0.1
const MAX_AFTERAIR_TIME = 0.25
const WALK_SPEED = 150 # pixels/sec
const JUMP_SPEED = 300
const SIDING_CHANGE_SPEED = 10
const BULLET_VELOCITY = 1000
const SHOOT_TIME_SHOW_WEAPON = 0.2
const MIN_NO_WALL_TIME = 0.75

var gravity = GRAVITY_VEC
var linear_vel = Vector2()
var air_speed = 0
var afterair_time = 0
var onair_time = 0 #
var on_floor = false
var shoot_time=99999 #time since last shot

var on_wall = false
var no_wall_time = 0
var wall_slide = false


var anim=""
var health = 10
var health_max = 10
var damage = false
var enemy = null

onready var ray_wall_r = $'check_wall_r'
onready var ray_wall_l = $'check_wall_l'
onready var sprite = $'body'
onready var audio = $'audio_player'

var can_wall_jump = true

export(int, 1,2) var player_id = 1

var audio_jump = preload('res://sound/jump.ogg')
var audio_landing = preload('res://sound/landing.ogg')
var audio_damage = preload('res://sound/player_damage.wav')
var audio_shoot = preload('res://sound/player_shoot.wav')


#cache the sprite here for fast access (we will set scale to flip it often)


func _physics_process(delta):
	#increment counters

	onair_time+=delta
	shoot_time+=delta

	# FIX GRAVITY
	
	
	if (ray_wall_r.is_colliding() or ray_wall_l.is_colliding()) and not on_floor and on_wall:
		if linear_vel.y > 0:
			gravity = LOW_GRAVITY_VEC
			linear_vel.y = lerp(linear_vel.y, 50, 10* delta)
		else:
			gravity = GRAVITY_VEC
	else:
		gravity = GRAVITY_VEC
		on_wall = false
	
	if wall_slide and on_wall:
		no_wall_time += delta
		if no_wall_time >= MIN_NO_WALL_TIME:
			gravity = GRAVITY_VEC
			no_wall_time = 0
			wall_slide = false
			on_wall = false
	
	### MOVEMENT ###

	# Apply Gravity
	linear_vel += delta * gravity
	# Move and Slide
	linear_vel = move_and_slide( linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP )
	# Detect Floor
	if (is_on_floor()):
		onair_time = 0
	
	if on_floor == false and is_on_floor():
		play_audio(audio_landing)
	on_floor = onair_time < MIN_ONAIR_TIME

	### CONTROL ###
	
	if Input.is_action_pressed('jump_' + str(player_id)) == false and can_wall_jump == false and linear_vel.y > 35:
		can_wall_jump = true
	
	# Horizontal Movement
	var target_speed = 0
	if not damage:
		if on_wall:
			wall_slide = true
			if ray_wall_r.is_colliding():
				if Input.is_action_pressed('jump_' + str(player_id)):
					if (Input.is_action_pressed('move_left_' + str(player_id))):
						linear_vel.y=-JUMP_SPEED*1.2
						target_speed += -2
						air_speed += clamp(air_speed + 0.01, 0, 1)
						can_wall_jump = false
						play_audio(audio_jump)
						gravity = GRAVITY_VEC
						ray_wall_r.set_enabled(false)
						get_tree().create_timer(0.25).connect('timeout', ray_wall_r, 'set_enabled', [true])
					elif can_wall_jump:
						linear_vel.y=-JUMP_SPEED*1.1
						target_speed += -2
						can_wall_jump = false
						play_audio(audio_jump)
						gravity = GRAVITY_VEC
						ray_wall_r.set_enabled(false)
						get_tree().create_timer(0.25).connect('timeout', ray_wall_r, 'set_enabled', [true])
				
			elif ray_wall_l.is_colliding():
				if Input.is_action_pressed('jump_' + str(player_id)):
					if (Input.is_action_pressed('move_right_' + str(player_id))):
						linear_vel.y=-JUMP_SPEED*1.2
						target_speed += 2
						air_speed += clamp(air_speed + 0.01, 0, 1)
						can_wall_jump = false
						play_audio(audio_jump)
						gravity = GRAVITY_VEC
						ray_wall_l.set_enabled(false)
						get_tree().create_timer(0.25).connect('timeout', ray_wall_l, 'set_enabled', [true])
					elif can_wall_jump:
						linear_vel.y=-JUMP_SPEED*1.1
						target_speed += 2
						can_wall_jump = false
						play_audio(audio_jump)
						gravity = GRAVITY_VEC
						ray_wall_l.set_enabled(false)
						get_tree().create_timer(0.25).connect('timeout', ray_wall_l, 'set_enabled', [true])
			else:
				wall_slide = false
				no_wall_time = 0
		else:
			if (Input.is_action_pressed('move_left_' + str(player_id))):
				target_speed += -1
				if ray_wall_l.is_colliding() and not on_floor:
					on_wall = true
			if (Input.is_action_pressed('move_right_' + str(player_id))):
				target_speed +=  1
				if ray_wall_r.is_colliding() and not on_floor:
					on_wall = true
			
	
	else:
		if enemy != null:
			target_speed = Vector2(position.x - enemy.position.x, 0).normalized().x * 10
		damage = false
		linear_vel.y=-JUMP_SPEED/2
		play_audio(audio_damage)
	
	if afterair_time > MAX_AFTERAIR_TIME:
		air_speed = 0
	
	target_speed = (target_speed + target_speed* air_speed) * WALK_SPEED
	
	if on_floor or on_wall:
		afterair_time += delta
		linear_vel.x = lerp( linear_vel.x, target_speed, 0.25 )
	else:
		afterair_time = 0
		linear_vel.x = lerp( linear_vel.x, target_speed, 5 * delta )
	# Jumping
	if (on_floor and Input.is_action_just_pressed('jump_' + str(player_id))):
		can_wall_jump = false
		linear_vel.y=-JUMP_SPEED
		air_speed = clamp(air_speed + 0.01, 0, 1)
		play_audio(audio_jump)

	# Shooting

	if (Input.is_action_just_pressed("shoot_" + str(player_id))):

		var bullet = preload('res://Scenes/bullet.tscn').instance()
		bullet.position = $'body/bullet_spawn'.global_position #use node for shoot position
		bullet.dir = ($'body/bullet_spawn'.global_position - $'body'.global_position ).normalized()
		bullet.add_collision_exception_with(self) # don't want player to collide with bullet
		get_parent().add_child( bullet ) #don't want bullet to move with me, so add it as child of parent
		shoot_time=0
		play_audio(audio_shoot)


	### ANIMATION ###

	var new_anim='idle'
	var body_scale = sprite.scale.x
	if on_wall:
		if ray_wall_l.is_colliding():
			body_scale = 1
		elif ray_wall_r.is_colliding():
			body_scale = -1
		new_anim = 'slide'
	elif (on_floor):
		if anim == 'falling':
				new_anim = 'bounce'
		else:
			if (linear_vel.x < -SIDING_CHANGE_SPEED):
				body_scale = -1
				new_anim='run'
	
			if (linear_vel.x > SIDING_CHANGE_SPEED):
				body_scale = 1
				new_anim='run'

	else:
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if (Input.is_action_pressed('move_left_' + str(player_id)) and not Input.is_action_pressed('move_right_' + str(player_id))):
			body_scale = -1
		if (Input.is_action_pressed('move_right_' + str(player_id)) and not Input.is_action_pressed('move_left_' + str(player_id))):
			body_scale = 1

		if (linear_vel.y < 0 ):
			new_anim='jumping'
		else:
			new_anim='falling'
#	if (shoot_time < SHOOT_TIME_SHOW_WEAPON):
#		new_anim+="_weapon"
	sprite.scale.x = body_scale
	
	
	if (new_anim!=anim):
		if $'anim'.get_current_animation() in ['bounce', 'damage']:
			pass
		else:
			anim=new_anim
			get_node('anim').play(anim)
	
	if position.y > 200:
		damage (9999, self)


func play_audio(sample):
	if sample is AudioStreamOGGVorbis or sample is AudioStreamSample or sample is AudioStreamRandomPitch:
		if audio.stream.audio_stream != sample:
			audio.stream.audio_stream = sample
		audio.play()


func die():
	if has_node('../cameras/cam'):
		$'../cameras/cam'.targets.erase(self)
	queue_free()

func damage (val, body):
	enemy = body
	health -= val
	damage = true
	$'anim'.play('damage')
	if health <= 0:
		set_physics_process(false)
		get_node('anim').play('die')
	get_tree().call_group('ui', 'update_health')

func _ready():
	if has_node('../cameras/cam'):
		$'../cameras/cam'.targets.append (self)

func _on_floor_kill_body_entered( body ):
	if body.has_method('damage'):
		body.damage(1.0)
		linear_vel.y = -JUMP_SPEED
	
