extends Sprite

func _ready():
	randomize()
	modulate = Color(randf(), randf(), randf(), 1)
