extends Control

signal save_pressed

func _ready():
	get_tree().paused = true

func _on_quit_pressed():
	unpause()
	get_tree().change_scene_to_file("res://Menu/menu.tscn")

func load_settings(can_load: bool, can_save: bool):
	if !can_load:
		$CanvasLayer/CenterContainer/VBoxContainer/Load.visible = false
	if !can_save:
		$CanvasLayer/CenterContainer/VBoxContainer/Save.visible = false

func _on_resume_pressed():
	unpause()
	queue_free()

func _on_save_pressed():
	unpause()
	save_pressed.emit()

func _on_load_pressed():
	unpause()
	get_tree().change_scene_to_file("res://World/world.tscn")

func unpause():
	get_tree().paused = false
