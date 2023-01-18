extends KinematicBody2D

const EnemyDeathEffect = preload("res://Effects/EnemyDeathEffect.tscn")

enum {
	IDLE,
	WANDER,
	CHASE
}
var state = CHASE

export var ACCELERATION = 300
export var MAX_SPEED = 50
export var FRICTION = 200
export var KNOCKBACK_FRICTION = 200 # 200
export var KNOCKBACK_STRENGTH = 120 # 120

var velocity = Vector2.ZERO
var knockback = Vector2.ZERO

onready var stats = $Stats
onready var playerDetectionZone = $PlayerDetectionZone

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, KNOCKBACK_FRICTION * delta)
	knockback = move_and_slide(knockback)
	
	match state:
		IDLE:
			velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
			seek_player()
			
		WANDER:
			pass
			
		CHASE:
			pass

func seek_player():
	if playerDetectionZone.can_see_player(): # Calling down/ signaling up
		state = CHASE

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage # Calling Down
	knockback = area.knockback_vector * KNOCKBACK_STRENGTH

func _on_Stats_no_health():
	queue_free() # Signaling Up
	
	# Generating a death effect
	var enemyDeathEffect = EnemyDeathEffect.instance()
	get_parent().add_child(enemyDeathEffect)
	enemyDeathEffect.global_position = global_position
