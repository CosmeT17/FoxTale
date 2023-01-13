extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

const FRICTION = 200 # 200
const KNOCKBACK_STRENGTH = 120 # 120

var knockback = Vector2.ZERO

onready var stats = $Stats

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage # Calling Down
	knockback = area.knockback_vector * KNOCKBACK_STRENGTH

func _on_Stats_no_health():
	queue_free() # Signaling Up
	
	# Generating a death effect
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
