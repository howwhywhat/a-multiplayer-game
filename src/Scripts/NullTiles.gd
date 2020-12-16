extends TileMap

onready var WATER_SCENE = preload("res://src/Scenes/Liquid.tscn")
var randomPos = ["WaterPositions/Position1", 
	"WaterPositions/Position2", 
	"WaterPositions/Position3"]

func _ready():
	yield(get_tree().create_timer(0.5), "timeout")
	for x in range(0, 301):
		print(x)
		var water = WATER_SCENE.instance()
		
		randomize()
		var selection = randomPos[randi() % randomPos.size()]
		var choice = get_parent().get_node(selection)
		water.global_position = choice.global_position
		get_parent().add_child(water)
