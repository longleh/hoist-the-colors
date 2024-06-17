extends CharacterBody2D

@onready var animation_tree = $AnimationTree
@onready var animation_state = $AnimationTree.get("parameters/playback")
@onready var inv_time = $Invulnerability
signal update_target(orc: Node2D)
signal death(orc: Node2D)
var target_position: Vector2 = Vector2(0, 0)
var MAX_SPEED = 50
var ACCELERATION = 200
var HIT_KNOCKBACK = 25
var HITPOINT = 3
var invulnerable = false

enum {
	INACTIVE,
	SPAWNED,
	DEATH,
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


func get_input_vector():
	var input_vector: Vector2 = target_position - position
	
	if input_vector.abs() <= Vector2(1, 1):
		return Vector2.ZERO

	return input_vector.normalized()

func spawn(target: Vector2):
	current_state = SPAWNED
	set_target(target)
	
func hit():
	if invulnerable || current_state == DEATH:
		return
	HITPOINT -= 1
	if HITPOINT == 0:
		return kill()
	invulnerable = true
	$Sprite2D.material.set_shader_parameter("hit", true)
	inv_time.start()
	var tween = get_tree().create_tween()
	var input_vec = get_input_vector() if get_input_vector() != Vector2.ZERO else animation_tree.get("parameters/Idle/blend_position")
	var opposite_vec = input_vec * -HIT_KNOCKBACK
	var new_position = position + opposite_vec
	tween.tween_property(self, "position", new_position , 0.3).set_trans(Tween.TRANS_LINEAR)

func kill():
	$Sprite2D.material.set_shader_parameter("death", true)
	$DespawnTimer.start()
	$DeathSound.playing = true
	current_state = DEATH
	animation_state.travel("Idle")

func _on_new_target_timer_timeout():
	update_target.emit(self)

func _on_invulnerability_timeout():
	$Sprite2D.material.set_shader_parameter("hit", false)
	invulnerable = false

func _on_despawn_timer_timeout():
	$DeathSound.playing = false
	death.emit(self)
	queue_free()
	
func stop():
	current_state = INACTIVE
	$Hurtbox.disabled = true
	
func resume():
	current_state = SPAWNED
	$Hurtbox.disabled = false

