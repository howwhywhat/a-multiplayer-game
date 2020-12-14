extends Node

class_name StateMachine

var state = null setget set_state
var previous_state = null
var states = {}

onready var parent = get_parent()

# Add your states in a ready function
# add_state("blah blah blah")
# To set your first state, use call_deferred
# call_deferred("set_state", states.<state>

func _physics_process(delta):
	if state != null:
		_state_logic(delta)
		var transition = _get_transition(delta)
		
		if transition != null:
			set_state(transition)

# Abstract functions that need to be copied over
func _state_logic(delta):
	pass
	# Use if statements to check the state, and then execute the logic (methods from the parent) for the state
	# You can also put general logic that allows to all states (like gravity) in this method

func _get_transition(delta):
	return null
	# You can use an enum (match state: blah blah blah) to check if the state machine can transition to that state
	# So if the player is looking away from the enemy, transition to the attack state, if not, then do not transition to the attack state
	# To transition to a state, use a return statement

func _enter_state(new_state, old_state):
	pass
	# You can use an enum (match state: blah) to execute code (like changing the AnimationPlayer) or call a method

func _exit_state(old_state, new_state):
	pass
# Abstract functions end here

# Sets the state
func set_state(new_state):
	previous_state = state
	state = new_state
	
	if previous_state != null:
		_exit_state(previous_state, new_state)

	if new_state != null:
		_enter_state(new_state, previous_state)

func add_state(state_name):
	states[state_name] = states.size()
	# A cleaner implementation, can allow you to print a list of your states, etc.
