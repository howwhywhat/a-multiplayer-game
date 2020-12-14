extends Control

func _ready():
	get_tree().refuse_new_network_connections = false
	get_tree().connect("connected_to_server", self, "connected")
	get_tree().connect("connection_failed", self, "no_connection")
	get_tree().connect("server_disconnected", self, "server_disconnected")

func connected():
	if Network.is_host and Network.current_players == Network.MAX_PLAYERS:
		rpc("begin_game")
		begin_game()
	else:
		if not Network.is_host:
			rpc_id(0, "player_joined")

func server_disconnected():
	get_tree().current_scene.camera.targets.clear()
	get_tree().current_scene.queue_free()
	get_tree().current_scene = self
	$Connecting.text = "Lost connection to server"
	get_tree().set_network_peer(null)
	get_tree().refuse_new_network_connections = false
	show()

func no_connection():
	$Connecting.text = "No connection"
	get_tree().set_network_peer(null)
	get_tree().refuse_new_network_connections = false

remote func player_joined():
	Network.current_players += 1
	connected()

remote func begin_game():
	var game = load("res://src/Scenes/Game.tscn").instance()
	get_tree().get_root().add_child(game)
	get_tree().current_scene = game
	hide()
