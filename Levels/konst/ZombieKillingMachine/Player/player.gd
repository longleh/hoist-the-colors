extends Node2D

@onready var projectile_scene = preload("res://Levels/konst/ZombieKillingMachine/Player/projectile.tscn")
@onready var fire_cooldown = $FireCooldown

var pierce = 1

var can_shoot = true

signal move(y: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_pressed("shandr_attack") && can_shoot:
		var projectile_node = projectile_scene.instantiate()
		projectile_node.position = $PlayerBody.position
		add_child(projectile_node)
		projectile_node.go(pierce)
		fire_cooldown.start()
		can_shoot = false
	var movement = int(Input.is_action_just_pressed("ui_right")) - int(Input.is_action_just_pressed("ui_left"))

	if movement != 0:
		move.emit(movement)

func body() -> Node2D:
	return $PlayerBody


func improve(type: String):
	if type.contains("FIRE_CD"):
		var current_cd = $FireCooldown.wait_time
		if current_cd > 0.05:
			var sub_cb = snappedf(current_cd - (current_cd * 0.1), 0.001)
			$FireCooldown.wait_time = maxf(0.05, sub_cb)
	elif type.contains("PIERCE"):
		if pierce < 5:
			pierce += 1

func get_cd() -> float:
	return $FireCooldown.wait_time

func get_pierce() -> int:
	return pierce

func _on_fire_cooldown_timeout():
	fire_cooldown.stop()
	can_shoot = true
