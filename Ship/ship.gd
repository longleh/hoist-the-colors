extends CharacterBody2D

var ACCELERATION = 700
var MAX_SPEED = 100

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")
var can_move = true

# add a friction system
# fix movement (not smooth on diag) maybe due to tmp texture

func _physics_process(delta):
	if can_move:
		compute_velocity_and_animate(delta)

func compute_velocity_and_animate(delta):
	var input_vector = Vector2.ZERO
	input_vector.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_vector.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	input_vector = input_vector.normalized()

	animate(input_vector)
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity = Vector2.ZERO
	move()

func move():
	if can_move:
		move_and_slide()

func animate(input_vector: Vector2):
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Move/blend_position", input_vector)
		animation_state.travel("Move")
	else:
		animation_state.travel("Idle")

func resume_movement():
	can_move = true

func stop_movement():
	animation_state.travel("Idle")
	velocity = Vector2.ZERO
	move()
	can_move = false
