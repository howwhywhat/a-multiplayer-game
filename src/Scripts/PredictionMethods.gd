extends Line2D

var y_level : float = -11

var outside_delta
var player : KinematicBody2D
var max_points : int = 900

func _ready():
	name = player.name + "prediction"

func _process(delta):
	outside_delta = delta

func update_trajectory(delta):
	clear_points()
	
	var pos = player.global_position
	var vel = player.global_transform.x * player.motion
	for i in max_points:
		add_point(pos)
		vel.y += player.GRAVITY * delta
		pos += vel * delta
		if pos.y > y_level:
			break

func _on_Update_timeout():
	update_trajectory(outside_delta)
