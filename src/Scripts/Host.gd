extends Button

signal set_connect_type

func _ready():
	$IP.text = "IP: " + str(IP.get_local_addresses()[7])

func host():
	var peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_NONE)
	var err = peer.create_server(Network.RPC_PORT, Network.MAX_PLAYERS)
	
	if err != OK:
		get_parent().get_node("Connecting").show()
		get_parent().get_node("Connecting").text = "Port already binded"
		return
	
	Network.initialize_server()
	get_tree().set_network_peer(peer)
	
	set_disabled(true)
	get_parent().get_node("Join").set_disabled(true)
	emit_signal("set_connect_type", true)
	
	for nodes in get_tree().get_nodes_in_group("Slots"):
		nodes.disabled = true
