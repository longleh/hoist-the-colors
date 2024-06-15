extends Node

signal save_data

var pause_menu_scene = preload("res://Menu/pause_menu.tscn")
var pause_menu_displayed = false
var pause_menu = null

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if !pause_menu_displayed && Input.is_action_just_pressed("pause"):
		pause_menu_displayed = true
		pause_menu = pause_menu_scene.instantiate()
		pause_menu.connect("tree_exiting", pause_menu_exit)
		pause_menu.connect("save_pressed", save_pressed)
		add_child(pause_menu)
	elif pause_menu_displayed && Input.is_action_just_pressed("pause"):
		pause_menu_displayed = false
		pause_menu.unpause()
		pause_menu.queue_free()
		pause_menu = null

func pause_menu_exit():
	pause_menu_displayed = false
	
func save_pressed():
	pause_menu_displayed = false
	pause_menu.queue_free()
	save_data.emit()
