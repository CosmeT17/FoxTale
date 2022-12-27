extends KinematicBody2D

const ACCELERATION = 500 # 500
const MAX_SPEED = 80 # 80
const FRICTION = 500 # 500
const ROLL_SPEED = 110 # 120
const START_DIRECTION = Vector2.LEFT

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

func _ready():
	# Set blend position to the initial looking direction
	animationTree.set("parameters/Idle/blend_position", START_DIRECTION)
	animationTree.set("parameters/Attack/blend_position", START_DIRECTION)
	animationTree.set("parameters/Roll/blend_position", START_DIRECTION)
	# Roll
	
#	roll_vector = START_DIRECTION
	
	# Activate animation tree to be able to play animations
	animationTree.active = true

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

# Called when the node enters the scene tree for the first time.
#func _ready():
#	print("Hello World")

# Runs every physics step, delta is the time (in seconds) that the last frame took to process
# Function runs about 1/60 seconds usually
#func _physics_process(delta):
	# Better Method, but faster at the diagonals
#	var input_vector = Vector2.ZERO
#	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	
	# normalized() makes the length of the vector always equal to 1 -> slower at diagonals
#	input_vector = input_vector.normalized()

#	if input_vector != Vector2.ZERO:
#		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		
#		velocity += input_vector * ACCELERATION * delta
#		# Cap belocity at MAX_SPEED
#		velocity = velocity.limit_length(MAX_SPEED)
	
#	else:
#		velocity = Vector2.ZERO
#		velocity = velocity.move_toward(Vector2.ZERO, FRICTION * delta)
	
	# Multiply by delta: Change from one pixel per frame -> x pixels per second
	# velocity relative to frame rate, slower frame rate -> faster and vice versa
#	move_and_collide(velocity * delta)
	
	# Better Method
#	var input_vector = Vector2.ZERO
#	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
#	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
#
#	if input_vector != Vector2.ZERO:
#		velocity = input_vector
#	else:
#		velocity = Vector2.ZERO
#
#	move_and_collide(velocity)
	
	# Bad Method
#	if Input.is_action_pressed("ui_right"):
#		velocity.x = 4
#	elif Input.is_action_pressed("ui_left"):
#		velocity.x = -4
#	elif Input.is_action_pressed("ui_up"):
#		velocity.y = -4
#	elif Input.is_action_pressed("ui_down"):
#		velocity.y = 4
#	else:
#		velocity.x = 0
#		velocity.y = 0
	
#	move_and_collide(velocity)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
