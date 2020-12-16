extends RigidBody2D

onready var BULLET_IMPACT_SCENE = preload("res://src/Scenes/BulletImpact.tscn")
export (float) var rate_of_fire = 0.4
export (int, 0, 1500) var projectile_speed = 400

func _ready():
	apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))

func _on_Bullet_body_entered(body):
	if body.is_in_group("Player"):
		print("hit player")
	instance_bullet_impact()

func instance_bullet_impact():
	var impact = BULLET_IMPACT_SCENE.instance()
	impact.global_position = global_position
	get_parent().add_child(impact)
