extends Control

@onready var audio_theme = $AudioStreamPlayer
var saved_game = false

func _ready():
	audio_theme.set("playing", true)
	saved_game = $Save.does_save_exists()
	if saved_game:
		$VBoxContainer/Play.set("text", "Continue")
		$VBoxContainer/Restart.visible = true

func _exit_tree():
	audio_theme.set("playing", false)

func _on_play_pressed():
	if saved_game:
		get_tree().change_scene_to_file("res://World/world.tscn")
	else:
		get_tree().change_scene_to_file("res://Levels/intro/intro.tscn")

func _on_quit_pressed():
	get_tree().quit()


func _on_restart_pressed():
	$Save.delete_save()
	saved_game = false
	_on_play_pressed()


func _on_restart_focus_entered():
	$RestartWarning.visible = true


func _on_restart_focus_exited():
	$RestartWarning.visible = false
