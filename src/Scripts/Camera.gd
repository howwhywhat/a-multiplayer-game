extends Camera2D

export (OpenSimplexNoise) var noise
export (float, 0, 1) var trauma = 0.0

export var max_x = 150
export var max_y = 150
export var max_r = 45

export var time_scale = 100

export (float, 0, 1) var decay = 0.6

var time = 0

export var move_speed = 0.5
export var zoom_speed = 0.25
export var min_zoom = 0.65
export var max_zoom = 5
export var margin = Vector2(90, 90)

var targets = []

onready var screen_size = get_viewport_rect().size

func add_trauma(trauma_in):
	trauma = clamp(trauma + trauma_in, 0.0, 1)

func add_target(t):
	if not t in targets:
		targets.append(t)

func remove_target(t):
	if t in targets:
		targets.remove(t)

func _process(delta):
	if !targets:
		return
	var p = Vector2.ZERO
	for target in targets:
		p += target.position
	p /= targets.size()
	position = lerp(position, p, move_speed)
	
	var r = Rect2(position, Vector2.ONE)
	for target in targets:
		r = r.expand(target.position)
	r = r.grow_individual(margin.x, margin.y, margin.x, margin.y)
	var d = max(r.size.x, r.size.y)
	var z
	if r.size.x > r.size.y * screen_size.aspect():
		z = clamp(r.size.x / screen_size.x, min_zoom, max_zoom)
	else:
		z = clamp(r.size.y / screen_size.y, min_zoom, max_zoom)
	zoom = lerp(zoom, Vector2.ONE * z, zoom_speed)
	
	time += delta
	
	var shake = pow(trauma, 2)
	offset.x = noise.get_noise_3d(time * time_scale, 0, 0) * max_x * shake
	offset.y = noise.get_noise_3d(0, time * time_scale, 0) * max_y * shake
	rotation_degrees = noise.get_noise_3d(0, 0, time * time_scale) * max_r * shake
	
	if trauma > 0.0: trauma = clamp(trauma - (delta * decay), 0.0, 1)
