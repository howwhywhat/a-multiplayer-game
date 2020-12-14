extends Node2D

var PREDICTION_SCENE = preload("res://src/Scenes/Prediction.tscn")

func _ready():
	yield(get_tree().create_timer(0.2), "timeout")
	for nodes in get_tree().get_nodes_in_group("Player"):
		var prediction = PREDICTION_SCENE.instance()
		prediction.player = nodes
		get_tree().current_scene.add_child(prediction)
