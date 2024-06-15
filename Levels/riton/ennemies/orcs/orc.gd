extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")
signal update_target(orc: Node2D)
var target_position: Vector2 = Vector2(0, 0)
var MAX_SPEED = 50
var ACCELERATION = 200
var NUMBER_OF_RENDERS_BEFORE_UPDATING_TARGET = 10
var current_render_cycle = 0

enum {
	INACTIVE,
	SPAWNED
}

var current_state = INACTIVE

func set_target(target: Vector2):
	target_position = target
	
func _physics_process(delta):
	match current_state:
		SPAWNED:
			process_active(delta)

func process_active(delta):
	var input_vector = get_input_vector()
	
	if input_vector != Vector2.ZERO:
		velocity = velocity.move_toward(input_vector * MAX_SPEED, ACCELERATION * delta)
		animation_tree.set("parameters/Idle/blend_position", velocity.normalized())
		animation_tree.set("parameters/Run/blend_position", velocity.normalized())
		animation_state.travel("Run")
		move_and_slide()
	else:
		animation_state.travel("Idle")
	current_render_cycle += 1
	if current_render_cycle == NUMBER_OF_RENDERS_BEFORE_UPDATING_TARGET:
		update_target.emit(self)
		current_render_cycle = 0
	

func get_input_vector():
	var input_vector: Vector2 = target_position - position
	
	if input_vector.abs() <= Vector2(5, 5):
		return Vector2.ZERO

	return input_vector.normalized()

func spawn(target: Vector2):
	current_state = SPAWNED
	set_target(target)
