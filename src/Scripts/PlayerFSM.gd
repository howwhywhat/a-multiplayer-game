extends StateMachine

var state_logic_enabled = true

func _ready():
	add_state("idle")
	add_state("walk")
	add_state("death")
	add_state("jump")
	add_state("wall_slide")
	add_state("fall")
	call_deferred("set_state", states.idle)

func _state_logic(delta):
	if parent.is_master:
		parent.apply_gravity(delta)
		parent.start_movement()
		if state_logic_enabled == true:
			parent.apply_movement(delta)
			parent.apply_jumping(delta)
			
			if state == states.idle:
				if parent.moveOrDieHealth > 0:
					parent.moveOrDieHealth -= 1
				parent.emit_signal("player_idle", parent.moveOrDieHealth)
			elif state == states.walk:
				if parent.moveOrDieHealth > 0 and parent.moveOrDieHealth < parent.moveOrDieMaxHealth:
					parent.moveOrDieHealth += 1
				parent.emit_signal("player_idle", parent.moveOrDieHealth)
			
			if state == states.wall_slide:
				parent.wall_slide_drop_check(delta)
				parent.wall_slide_fast_slide_check(delta)
				parent.apply_wall_slide_jump(parent.get_wall_axis())

func _get_transition(delta):
	match state:
		states.idle:
			parent.stateText.text = "idle"
			if parent.is_on_floor():
				if parent.x_input != 0:
					return states.walk
			else:
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					return states.jump
				if parent.motion.y > 0 && parent.was_on_floor && parent.coyoteTimer.is_stopped():
					return states.fall
			if parent.moveOrDieHealth <= 0:
				return states.death
		states.walk:
			parent.stateText.text = "walk"
			if parent.is_on_floor():
				if parent.x_input == 0:
					return states.idle
			else:
				if parent.is_on_wall():
					return states.wall_slide
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					return states.jump
				if parent.motion.y > 0 && parent.was_on_floor && parent.coyoteTimer.is_stopped():
					return states.fall
			if parent.moveOrDieHealth <= 0:
				return states.death
		states.jump:
			parent.stateText.text = "jump"
			if parent.is_on_floor():
				if parent.x_input == 0:
					return states.idle
				if parent.x_input != 0:
					return states.walk
			else:
				if parent.is_on_wall():
					return states.wall_slide
				if parent.motion.y > 0 && parent.was_on_floor && parent.coyoteTimer.is_stopped():
					return states.fall
			if parent.moveOrDieHealth <= 0:
				return states.death
		states.fall:
			parent.stateText.text = "fall"
			if parent.is_on_floor():
				if parent.x_input == 0:
					return states.idle
				if parent.x_input != 0:
					return states.walk
			else:
				if parent.is_on_wall():
					return states.wall_slide
				if parent.motion.y < 0 and !parent.jumpBuffer.is_stopped():
					return states.jump
			if parent.moveOrDieHealth <= 0:
				return states.death
		states.wall_slide:
			parent.stateText.text = "wall_slide"
			if parent.get_wall_axis() == 0 or parent.is_on_floor():
				return states.idle
			if parent.moveOrDieHealth <= 0:
				return states.death
	return null

func _enter_state(new_state, old_state):
	match new_state:
		states.idle:
			# play animation
			parent.animation.play("idle")
			parent.rpc("update_animations", "idle")
		states.walk:
			parent.animation.play("walk")
			parent.rpc("update_animations", "walk")
		states.wall_slide:
			parent.animation.play("wall_slide")
			parent.rpc("update_animations", "wall_slide")
			
			# update the player scale depending on wall_axis (which way the player is facing)
			var wallAxis = parent.get_wall_axis()
			if wallAxis != 0:
				if parent.sprite.flip_h == false:
					parent.sprite.scale.x = wallAxis
					parent.rpc("update_scale", parent.sprite.scale.x)
				else:
					parent.sprite.scale.x = -wallAxis
					parent.rpc("update_scale", parent.sprite.scale.x)
		states.jump:
			parent.animation.play("jump")
			parent.rpc("update_animations", "jump")
			
			# stop the jump buffer timer so the player doesn't get an extra jump
			parent.jumpBuffer.stop()
		states.fall:
			parent.animation.play("fall")
			parent.rpc("update_animations", "fall")
			
			# start the coyote timer so the player has time to jump and recover
			parent.coyoteTimer.start()
		states.death:
			state_logic_enabled = false
			parent.flashAnimation.play("flash")
			parent.animation.play("death")
			parent.rpc("update_animations", "death")
			parent.rpc("play_flash_animation", "flash")

func _exit_state(old_state, new_state):
	match old_state:
		states.wall_slide:
			# updates the scale back to normal
			parent.sprite.scale.x = 1
			parent.rpc("update_scale", parent.sprite.scale.x)
