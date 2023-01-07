extends KinematicBody2D

const ACCELERATION = 500 # 500
const MAX_SPEED = 80 # 80
const FRICTION = 500 # 500
const ROLL_SPEED = 110 # 120
export var START_DIRECTION = Vector2.LEFT

enum {
	MOVE,
	ROLL, 
	ATTACK
}
var state = MOVE

var roll_vector = START_DIRECTION
var velocity = Vector2.ZERO
var downCounter = 0
var upCounter = 0

# Variable will not be initialized until the dependent child node is ready
onready var animationPlayer = $AnimationPlayer
onready var animationTree = $AnimationTree
onready var animationState = animationTree.get("parameters/playback")
onready var swordHitbox = $HitboxPivot/SwordHitbox

func _ready():
	# Set blend position to the initial looking direction
	animationTree.set("parameters/Idle/blend_position", START_DIRECTION)
	animationTree.set("parameters/Attack/blend_position", START_DIRECTION)
	animationTree.set("parameters/Roll/blend_position", START_DIRECTION)
	
	# Activate animation tree to be able to play animations
	animationTree.active = true
	
	# Sword knockback_vector initialized to the player's initial look direction
	swordHitbox.knockback_vector = START_DIRECTION

# TO DO: Implement strafing
func _physics_process(delta):
	match state:
		MOVE: 
			move_state(delta)
		
		ROLL:
			roll_state(delta)
		
		ATTACK:
			attack_state(delta)

# TO DO: Make either up/down/left/right or WASD, but not both
func move_state(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()
	
	var look_direction = input_vector
	
	# Moving up -> look up when moving left/right
	if input_vector.y == -1:
		if upCounter < 10:
			upCounter += 1
	elif upCounter > 7 && input_vector.y < 0 && input_vector.x != 0:
		look_direction = Vector2.UP
	else:
		upCounter = 0

	# Moving down -> look down when moving left/right
	if input_vector.y == 1:
		if downCounter < 10:
			downCounter += 1
	elif downCounter > 7 && input_vector.y > 0 && input_vector.x != 0:
		look_direction = Vector2.DOWN
	else:
		downCounter = 0

	if input_vector != Vector2.ZERO:
		# Roll and Sword Knockback vectors point to input_vector
		swordHitbox.knockback_vector = input_vector
		roll_vector = input_vector
		
		# Set blend position to the looking direction
		animationTree.set("parameters/Idle/blend_position", look_direction)
		animationTree.set("parameters/Run/blend_position", look_direction)
		animationTree.set("parameters/Attack/blend_position", look_direction)
		animationTree.set("parameters/Roll/blend_position", look_direction)
		
		# Travel to Run animation in AnimationTree
		animationState.travel("Run")
		
		# Increase velocity to MAX_SPEED at the rate of ACCELERATION
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		# Travel to Idle animation in AnimationTree
		animationState.travel("Idle")
		
		# Decrease velocity to ZERO at the rate of FRICTION
		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	move()
	
	if Input.is_action_just_pressed("roll"):
		state = ROLL
	
	if Input.is_action_just_pressed("attack"):
		state = ATTACK

func roll_state(delta):
	velocity = roll_vector * ROLL_SPEED
	animationState.travel("Roll")
	move()

# TO DO: Make space for up/down/left/right, else J for WASD
func attack_state(delta):
	velocity = Vector2.ZERO
	animationState.travel("Attack")

func move():
	velocity = move_and_slide(velocity)

func roll_animation_finished():
	velocity = velocity * 0.8
	state = MOVE

func attack_animation_finished():
	state = MOVE
