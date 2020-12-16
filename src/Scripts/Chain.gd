extends Node2D

onready var links = $Links
var direction : Vector2 = Vector2.ZERO
var tip : Vector2 = Vector2.ZERO

const SPEED = 50

var flying = false
var hooked = false

func shoot(dir: Vector2) -> void:
	direction = dir.normalized()
	flying = true
	tip = self.global_position

func release() -> void:
	flying = false
	hooked = false

func _process(_delta : float) -> void:
	visible = flying or hooked
	if not self.visible:
		return
	var tip_loc = to_local(tip)
	links.rotation = self.position.angle_to_point(tip_loc) - deg2rad(90)
	$Tip.rotation = get_angle_to(get_global_mouse_position())
	links.position = tip_loc
	links.region_rect.size.y = tip_loc.length()
	rpc_unreliable("set_visible", self.visible)
	rpc_unreliable("set_links_rotation", links.rotation)
	rpc_unreliable("set_tip_rotation", $Tip.rotation)
	rpc_unreliable("set_links_position", links.position)
	rpc_unreliable("set_links_region_rect", links.region_rect)

func _physics_process(_delta : float) -> void:
	$Tip.global_position = tip
	if flying:
		if $Tip.move_and_collide(direction * SPEED):
			hooked = true
			flying = false
	tip = $Tip.global_position

remote func set_tip_rotation(new_value):
	$Tip.rotation = new_value

remote func set_links_region_rect(new_value):
	links.region_rect = new_value

remote func set_links_position(new_value):
	links.position = new_value

remote func set_links_rotation(new_value):
	links.rotation = new_value

remote func set_visible(new_value):
	visible = new_value
