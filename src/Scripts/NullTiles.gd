extends TileMap

onready var liquidSim = $LiquidSim

var finalPos

func _ready():
	for node in get_tree().get_nodes_in_group("WaterPosition"):
		finalPos = world_to_map(node.position)
		liquidSim.add_liquid(finalPos.x, finalPos.y, 0.2)

func _process(_delta):
	for node in get_tree().get_nodes_in_group("Liquid"):
		node.rotation = get_parent().rotation
