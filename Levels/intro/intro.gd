extends Node2D

enum level_state {
	INTRO = 1,
	TAVERN = 2
}

var d_scene = preload("res://Dialogue/container/Dialogue.tscn")

var l_state: level_state = level_state.INTRO

func _ready():
	if l_state == level_state.INTRO:
		add_dialog("res://common/dialogs/intro_d.json")

func _on_dialogue_dialog_end():
	if l_state == level_state.TAVERN:
		get_tree().change_scene_to_file("res://World/world.tscn")
	elif l_state == level_state.INTRO:
		l_state = level_state.TAVERN
		$Blackscreen/BackgroundHider/AnimationPlayer.connect("animation_finished", _on_animation_finished)
		$Blackscreen/BackgroundHider/AnimationPlayer.play("smooth_alpha")	
		$TavernMusic.set("playing", true)
		$TavernMusic/AnimationPlayer.play("smooth_volume_up")

func _on_animation_finished(_arg):
	add_dialog("res://common/dialogs/intro_2_d.json")
	
func add_dialog(path):
	var d = d_scene.instantiate()
	d.set("dialog_file", path)
	d.connect("dialog_end", _on_dialogue_dialog_end)
	add_child(d)
	d.start_dialogue()
