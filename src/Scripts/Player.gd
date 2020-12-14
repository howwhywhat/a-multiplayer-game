extends KinematicBody2D

# debugging

# checking state
onready var stateText : Label = $DebugState

# cached variables

# movement timers
onready var coyoteTimer : Timer = $CoyoteTimer
onready var jumpBuffer : Timer = $JumpBuffer

onready var sprite : Sprite = $Texture
onready var animation : AnimationPlayer = $Animation
onready var flashAnimation : AnimationPlayer = $FlashAnimation

# movement

# general constants that hsould be global for every entity
const ACCELERATION = 512
const MAX_SPEED = 128
const FRICTION = 0.25
const AIR_RESISTANCE = 0.02
const JUMP_FORCE = 128
const GRAVITY = 200

# wall sliding variables
export (int) var WALL_SLIDE_SPEED = 48
export (int) var MAX_WALL_SLIDE_SPEED = 128

var motion : Vector2 = Vector2.ZERO
var x_input = 0

# coyote timer for jumping
var was_on_floor

# networking

# checking if a slave of the network
var is_master : bool = false
var uuid

# signals
signal player_idle(new_value)

# move or die functionality
onready var moveOrDie : TextureProgress = $MoveOrDie
export (int) var moveOrDieHealth = 100
export (int) var moveOrDieMaxHealth = 100

# death animation
onready var EXPLOSION_SCENE = preload("res://src/Scenes/ExplosionAnimation.tscn")

# initializes the player with an uuid on peer connect and initializes any node that's unique to them
func initialize(id):
	uuid = id
	name = str(id)
	moveOrDie.intitalize(moveOrDieHealth, moveOrDieMaxHealth)
	connect("player_idle", moveOrDie, "player_idle")
	get_parent().camera.add_target(self)
	get_parent().alivePlayers.append(self)
	if id == Network.net_id:
		is_master = true

# places move_and_slide outside of apply_movement method for gravity and etc
func start_movement():
	was_on_floor = is_on_floor() # checks if the player was on the ground before starting movement again
	motion = move_and_slide(motion, Vector2.UP)

# start x-axis movement
func apply_movement(delta):
	x_input = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")

	if x_input != 0:
		motion.x += x_input * ACCELERATION * delta
		motion.x = clamp(motion.x, -MAX_SPEED, MAX_SPEED)
		sprite.flip_h = x_input < 0
		rpc("update_sprite_flip_h", sprite.flip_h)

# start y-axis movement
func apply_jumping(delta):
	if is_on_floor() || !coyoteTimer.is_stopped():
		if x_input == 0:
			motion.x = lerp(motion.x, 0, FRICTION)
		
		if Input.is_action_just_pressed("ui_up"):
			motion.y = -JUMP_FORCE
			coyoteTimer.stop()
	else:
		jumpBuffer.start()
		if Input.is_action_just_pressed("ui_up") and motion.y < -JUMP_FORCE / 2:
			motion.y = -JUMP_FORCE / 2
			coyoteTimer.stop()
		
		if x_input == 0:
			motion.x = lerp(motion.x, 0, AIR_RESISTANCE)

# getting wall axis
func get_wall_axis():
	var is_right_wall = test_move(transform, Vector2.RIGHT)
	var is_left_wall = test_move(transform, Vector2.LEFT)
	return int(is_left_wall) - int(is_right_wall)

# wall slide jump functionality
func apply_wall_slide_jump(wall_axis):
	if Input.is_action_just_pressed("ui_up"):
		motion.x = wall_axis * 154
		motion.y = -JUMP_FORCE * 1.5

# able to drop
func wall_slide_drop_check(delta):
	if Input.is_action_pressed("ui_right"):
		motion.x = ACCELERATION * delta
	
	if Input.is_action_pressed("ui_left"):
		motion.x = -ACCELERATION * delta

# check if you can fast slide by holding down
func wall_slide_fast_slide_check(delta):
	var max_slide_speed = WALL_SLIDE_SPEED
	if Input.is_action_pressed("ui_down"):
		max_slide_speed = MAX_WALL_SLIDE_SPEED
	motion.y = min(motion.y + GRAVITY * delta, max_slide_speed)

# start gravity by adding it to motion.y
func apply_gravity(delta):
	if coyoteTimer.is_stopped():
		motion.y += GRAVITY * delta
		motion.y += GRAVITY * delta

# instance the explosion scene for the death anim
func instance_explosion():
	var explosion = EXPLOSION_SCENE.instance()
	var finalPos = global_position - Vector2(0, 5)
	explosion.global_position = finalPos
	explosion.rotation = rotation
	get_parent().add_child(explosion)

# send unreliable packets here (doesn't matter if they get lost, they'll be replaced eventually)
func _physics_process(delta):
	if is_master:
		if is_on_floor():
			if rotation > deg2rad(45) and rotation < deg2rad(125):
				sprite.scale.x = -1
				sprite.flip_v = true
			elif rotation > deg2rad(-120) and rotation < deg2rad(-40):
				sprite.scale.x = -1
				sprite.flip_v = true
			elif rotation > deg2rad(-120):
				sprite.scale.x = 1
				sprite.flip_v = false
			elif rotation < deg2rad(-40):
				sprite.scale.x = 1
				sprite.flip_v = false
		print(rad2deg(rotation))
		rotation = get_parent().rotation
		rpc_unreliable("update_rotation", rotation)
		rpc_unreliable("update_scale", sprite.scale.x)
		rpc_unreliable("update_sprite_flip_v", sprite.flip_v)
		rpc_unreliable("update_sprite_flip_h", sprite.flip_h)
		rpc_unreliable("update_position", position, delta)

func _on_Animation_animation_started(anim_name):
	rpc_unreliable("update_animations", anim_name)

# changes rotation
remote func update_rotation(new_rotation):
	rotation = new_rotation

# interpolates between last pos and current pos for player to get rid of any jitter in movement
remote func update_position(pos, delta):
	position = lerp(position, pos, FRICTION)

# updates the flip_h of the sprite
remote func update_sprite_flip_h(new_value):
	sprite.flip_h = new_value

# updates the flip_v of the sprite
remote func update_sprite_flip_v(new_value):
	sprite.flip_v = new_value

# updates the scale for all clients used for the wall sliding
remote func update_scale(new_value):
	sprite.scale.x = new_value

# sends a packet to change an animation based on the string passed from the rpc call
remote func update_animations(animationString):
	animation.play(animationString)

# play animation on flashanimation
remote func play_flash_animation(animationString):
	flashAnimation.play(animationString)

func _on_Animation_animation_finished(anim_name):
	if anim_name == "death":
		get_parent().delete_player(uuid)
