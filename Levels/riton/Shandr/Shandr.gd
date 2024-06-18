extends CharacterBody2D

var ACCELERATION = 700
var MAX_SPEED = 100

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")
signal sword_hit(body)
signal death()

var can_move = true
var is_attacking = false
var can_attack = true
var ennemies_in_range = 0
var invincible = false
@export var BASE_HITPOINT = 10
var hitpoint = BASE_HITPOINT

enum SHANDR_STATE {
	MOVING,
	ATTACKING,
	HIT,
	DEATH,
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
		SHANDR_STATE.HIT:
			hit_state()

func die(): 
	animation_state.travel("Idle")
	current_state = SHANDR_STATE.DEATH
	$Sprite2D.material.set_shader_parameter("dead", true)
	$AnimationPlayer.play("death")
	death.emit()

func hit_state():
	hitpoint -= 1
	handle_hp_bar()
	if hitpoint == 0:
		die()
	else:
		$AnimationPlayer.play("invulnerability")
		current_state = SHANDR_STATE.MOVING
		invincible = true

func handle_hp_bar():
	$HPBar.visible = true
	$HPBarDisplayTime.start()
	$HPBar.value = hitpoint
	var sb = StyleBoxFlat.new()
	if (hitpoint > 6):
		sb.bg_color = Color("#0FFF50")
	elif (hitpoint > 3):
		sb.bg_color = Color("#FFF01F")
	else:
		sb.bg_color = Color("#C8102E")
	$HPBar.add_theme_stylebox_override("fill", sb)

func attack_state():
	velocity = Vector2.ZERO
	animation_state.travel("Attack")

func move_state(delta):
	# sometimes hitbox isn't disabled because of animation overlapping
	# so disabling the hitbox is enforced here
	$SwordHitbox/CollisionShape2D.disabled = true
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
	if Input.is_action_just_pressed("shandr_attack") && can_attack:
		current_state = SHANDR_STATE.ATTACKING
		$WeaponSwing.playing = true

	if !invincible && ennemies_in_range > 0:
		current_state = SHANDR_STATE.HIT

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

func end_of_attack():
	$SwordHitbox/CollisionShape2D.disabled = true
	$WeaponSwing.playing = false
	current_state = SHANDR_STATE.MOVING

func resume_movement():
	can_move = true
	can_attack = true
	invincible = false

func stop_movement():
	animation_state.travel("Idle")
	velocity = Vector2.ZERO
	move()
	can_move = false
	can_attack = false
	invincible = true
	current_state = SHANDR_STATE.MOVING

func _on_sword_hitbox_body_shape_entered(_body_rid, body, _body_shape_index, _local_shape_index):
	sword_hit.emit(body)


func _on_hurtbox_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	ennemies_in_range += 1


func _on_hurtbox_body_shape_exited(_body_rid, _body, _body_shape_index, _local_shape_index):
	ennemies_in_range -= 1
	if ennemies_in_range < 0:
		ennemies_in_range = 0 # bug on despawn, ignore it for now  to not waste time

func _end_invicibility():
	invincible = false
	
func revive():
	velocity = Vector2.ZERO
	current_state = SHANDR_STATE.MOVING
	hitpoint = BASE_HITPOINT
	$Sprite2D.material.set_shader_parameter("dead", false)
	$Sprite2D.material.set_shader_parameter("invulnerable", false)
	invincible = false
	resume_movement()

func heal():
	$HPBar.visible = true
	$HealSound.playing = true
	var tween = get_tree().create_tween()
	tween.tween_method(_inner_heal, hitpoint, 10, 1)
	tween.tween_callback(func():
		$HealSound.playing = false
		_end_invicibility()
	)
	$AnimationPlayer.play("heal")
	
func _inner_heal(value):
	invincible = true
	hitpoint = value 
	handle_hp_bar()

func _on_hp_bar_display_time_timeout():
	$HPBar.visible = false
	$HPBarDisplayTime.stop()
	

func camera():
	return $Camera2D
