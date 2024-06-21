extends Node2D

@onready var projectile_scene = preload("res://Levels/konst/ZombieKillingMachine/Player/projectile.tscn")

signal move(y: int)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if Input.is_action_just_pressed("shandr_attack"):
		var projectile_node = projectile_scene.instantiate()
		projectile_node.position = $PlayerBody.position
		add_child(projectile_node)
		projectile_node.go()
	elif Input.is_action_just_pressed("ui_left"):
		move.emit(-1)
	elif Input.is_action_just_pressed("ui_right"):
		move.emit(1)
