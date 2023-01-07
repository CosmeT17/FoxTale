extends KinematicBody2D

const FRICTION = 200 # 200
const KNOCKBACK_STRENGTH = 120 # 120

var knockback = Vector2.ZERO

onready var stats = $Stats

func _physics_process(delta):
	knockback = knockback.move_toward(Vector2.ZERO, FRICTION * delta)
	knockback = move_and_slide(knockback)

func _on_Hurtbox_area_entered(area):
	stats.health -= area.damage # Calling Down
	
#	print(stats.health)
	
	knockback = area.knockback_vector * KNOCKBACK_STRENGTH

func _on_Stats_no_health():
	queue_free() # Signaling Up
