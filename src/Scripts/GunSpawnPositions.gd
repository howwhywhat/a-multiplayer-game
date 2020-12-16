extends Node2D

var gun1 = preload("res://src/Scenes/Bullet.tscn")
var guns = [gun1]

var positions = ["Position2D", "Position2D2", "Position2D3", "Position2D4", "Position2D5", "Position2D6", "Position2D7", "Position2D8", "Position2D9"]

remotesync func spawn_gun():
	randomize()
	var nodeChoice = positions[randi() % positions.size()]
	var choice = get_node(nodeChoice)
	var finalPos = choice.global_position
	
	var gunChoice = guns[randi() % guns.size()]
	var gun = gunChoice.instance()
	gun.global_position = finalPos
	get_parent().add_child(gun)

func _on_SpawnGunTimer_timeout():
	rpc("spawn_gun")
