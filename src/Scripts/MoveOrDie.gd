extends TextureProgress

onready var parent = get_parent()
var time_left = max_value

onready var tween : Tween = $Tween

func intitalize(current, maximum):
	max_value = maximum
	value = current

func _process(_delta):
	if parent.is_master:
		value = time_left
		rpc_unreliable("update_values", value, max_value)

func player_idle(new_value):
	tween.interpolate_property(self, "time_left", time_left, new_value, 1.0, Tween.TRANS_SINE, Tween.EASE_OUT)
	if not tween.is_active():
		tween.start()
	yield(tween, "tween_completed")

remote func update_values(new_value, new_max_value):
	value = new_value
	max_value = new_max_value
