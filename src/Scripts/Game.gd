extends Node2D

onready var camera = $Camera

var alivePlayers = []

func _ready():
	get_tree().refuse_new_network_connections = true
	get_tree().connect("network_peer_disconnected", self, "delete_player")
	# creates uuids
	Network.set_ids()
	# creates players
	create_players()

func create_players():
	# creates a player and passes the id as an arg to the func
	for id in Network.peer_ids:
		create_player(id)
	# creates the host player
	create_player(Network.net_id)

func create_player(id):
	# instances a new player
	var p = preload("res://src/Scenes/Player.tscn").instance()
	# spawns it at the position2d node
	p.position = $PlayerSpawns.position
	# adds it as a child to scene so it's accessible
	add_child(p)
	# calls the initialize method that adds the uuid, etc.
	p.initialize(id)

func delete_player(id):
	var p = get_node(str(id))
	var line = get_node(str(id) + "prediction")
	
	# removes target from the 2-player camera
	var cameraIndex = camera.targets.find(p, 0)
	# if can find player, then remove
	if cameraIndex != -1:
		camera.targets.remove(cameraIndex)
	
	# same as above but for checking if they're alive
	var aliveIndex = alivePlayers.find(p, 0)
	if aliveIndex != -1:
		alivePlayers.remove(aliveIndex)
	
	# removes itself from memory and the prediction method is removed as well
	if line != null:
		line.queue_free()
	if p != null:
		p.queue_free()
	
	# check if the game can end, and if yes then call end game
	if check_if_end():
		var whoWon = alivePlayers[0]
		var ifisMaster = whoWon.is_master
		rpc("end_game", ifisMaster)

func check_if_end() -> bool:
	if alivePlayers.size() != 1:
		return false
	else:
		return true

remote func end_game(ifMaster):
	var screen = load("res://src/Scenes/EndGameScreen.tscn").instance()
	if ifMaster:
		screen.get_node("Status").text = "You lost"
	else:
		screen.get_node("Status").text = "You won"
	add_child(screen)
	Engine.time_scale = 0.5
