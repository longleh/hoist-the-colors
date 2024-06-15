extends CharacterBody2D

var ACCELERATION = 700
var MAX_SPEED = 100

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")
signal sword_hit(body_rid, body)

var can_move = true
var is_attacking = false
var can_attack = true

enum SHANDR_STATE {
	MOVING,
	ATTACKING
}

var current_state: SHANDR_STATE = SHANDR_STATE.MOVING

# add a friction system
# fix movement (not smooth on diag) maybe due to tmp texture

func _ready():
	$SwordHitbox/CollisionShape2D.disabled = true

func _physics_process(delta):
	match current_state:
		SHANDR_STATE.MOVING:
			move_state(delta)
		SHANDR_STATE.ATTACKING:
			attack_state()

func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func move_state(delta):
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
	if Input.is_action_just_pressed("shandr_attack"):
		current_state = SHANDR_STATE.ATTACKING

func move():
	if can_move:
		move_and_slide()

func animate(input_vector: Vector2):
	if input_vector != Vector2.ZERO:
		animation_tree.set("parameters/Idle/blend_position", input_vector)
		animation_tree.set("parameters/Run/blend_position", input_vector)
		animation_tree.set("parameters/Attack/blend_position", input_vector)
		animation_state.travel("Run")
	else:
		animation_state.travel("Idle")

func animation_finshed_callback():
	$AnimationPlayer.disconnect("animation_finished", animation_finshed_callback)
	current_state = SHANDR_STATE.MOVING

func resume_movement():
	can_move = true

func stop_movement():
	animation_state.travel("Idle")
	velocity = Vector2.ZERO
	move()
	can_move = false


func _on_animation_player_animation_finished(_anim_name):
	current_state = SHANDR_STATE.MOVING


func _on_sword_hitbox_body_shape_entered(body_rid, body, body_shape_index, local_shape_index):
	sword_hit.emit(body_rid, body)
