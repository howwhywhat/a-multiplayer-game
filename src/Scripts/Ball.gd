extends RigidBody2D

var IMPACT_SCENE = preload("res://src/Scenes/Impact.tscn")

func _ready():
	rpc("start_animation", "autoload")

func _physics_process(delta):
	rpc_unreliable("update_position", position)

var saved_trans = null

slave func update_trans(t):
	saved_trans = t

func _integrate_forces(state):
	if saved_trans != null:
		state.transform = saved_trans
	else:
		rpc("update_trans", state.transform)

func _on_Ball_body_entered(body):
	var impact = IMPACT_SCENE.instance()
	impact.global_position = position
	get_parent().add_child(impact)
	get_parent().get_node("Camera").add_trauma(0.2)

remotesync func start_animation(anim_name):
	$Animation.play(anim_name)
