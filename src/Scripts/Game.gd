extends Node2D

onready var camera = $Camera

var purple = []
var yellow = []
var purplePoints = 0
var yellowPoints = 0

var alivePlayers = []
var spawns = ["yellow", "purple"]

var ended = false

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
	randomize()
	if Network.current_players == 2:
		var spawnChoice = spawns[randi() % spawns.size()]
		spawns.erase(spawnChoice)
		if spawnChoice == "yellow":
			p.global_position = $Spawns/YellowSpawn.global_position
		elif spawnChoice == "purple":
			p.global_position = $Spawns/PurpleSpawn.global_position
#	elif Network.current_players == 4:
#		var spawnChoice = spawns4[randi() % spawns4.size()]
#		spawns4.erase(spawnChoice)
#		var node = get_node(spawnChoice)
#		p.global_position = node.global_position

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
	
	# removes player from team
	if purple.has(p):
		purple.erase(p)
	elif yellow.has(p):
		yellow.erase(p)
	
	# removes itself from memory and the prediction method is removed as well
	if line != null:
		line.queue_free()
	if p != null:
		p.queue_free()
	
	# check if the game can end, and if yes then call end game
	if check_if_end() and not alivePlayers.empty():
		var whoWon = alivePlayers[0]
		var ifisMaster = whoWon.is_master
		rpc("end_game", ifisMaster, true)
		ended = true
	elif check_if_end() and alivePlayers.empty() and ended == false:
		ended = true
		rpc("end_game", null, false)

func check_if_end() -> bool:
	if purple.size() >= 1 and yellow.size() >= 1 and ended == true:
		return false
	else:
		return true

remote func spawn_ball():
	var ball = load("res://src/Scenes/Ball.tscn").instance()
	add_child(ball)
	ball.global_position = $BallSpawn.global_position

remote func end_game(ifMaster, ifnotEmpty):
	var screen = load("res://src/Scenes/EndGameScreen.tscn").instance()
	if ifnotEmpty:
		if ifMaster:
			screen.get_node("Status").text = "You lost"
		else:
			screen.get_node("Status").text = "You won"
	else:
		screen.get_node("Status").text = "Nobody won"
	add_child(screen)
	Engine.time_scale = 0.5

func _on_YellowTeamScoreDetector_body_entered(body):
	print(body)
	body.queue_free()
	purplePoints += 1
	
	if purplePoints >= 3:
		yellow[0].moveOrDieHealth = -1
	
	$ScoreLabels/PurpleTeam.text = str(purplePoints)
	$ScoreLabels/PurpleTeamShadow.text = str(purplePoints)
	$YellowScoreParticles.emitting = true
	$SpawnBall.play("spawn_ball")
	camera.add_trauma(1)

func _on_PurpleTeamScoreDetector_body_entered(body):
	print(body)
	body.queue_free()
	yellowPoints += 1

	if yellowPoints >= 3:
		purple[0].moveOrDieHealth = -1

	$ScoreLabels/YellowTeam.text = str(yellowPoints)
	$ScoreLabels/YellowTeamShadow.text = str(yellowPoints)
	$PurpleScoreParticles.emitting = true
	$SpawnBall.play("spawn_ball")
	camera.add_trauma(1)

func _on_PurpleTeamSelector_body_entered(body):
	purple.append(body)
	$PurpleTeamSelector.queue_free()

func _on_YellowTeamSelector_body_entered(body):
	yellow.append(body)
	$YellowTeamSelector.queue_free()
