extends Node

const RPC_PORT = 31400
var MAX_PLAYERS = 2
var current_players = 1
const TESTING_IP = "127.0.0.1"
const OFFLINE_TESTING = false

var net_id = null
var is_host = false
var peer_ids = []

func initialize_server():
	is_host = true

func initialize_client(server_ip):
	if OFFLINE_TESTING:
		server_ip = TESTING_IP
	var peer = NetworkedMultiplayerENet.new()
	peer.set_compression_mode(NetworkedMultiplayerENet.COMPRESS_NONE)
	peer.create_client(server_ip, RPC_PORT)
	get_tree().set_network_peer(peer)

func set_ids():
	net_id = get_tree().get_network_unique_id()
	peer_ids = get_tree().get_network_connected_peers()
