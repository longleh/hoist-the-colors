extends Node2D

signal island_touched(isle_name)
signal island_leaved(isle_name)

var enter_dialog_path = "res://common/dialogs/riton_isle_enter_d.json"
var visited = false

func _on_area_2d_body_entered(_body):
	island_touched.emit("RITON")

func load_level():
	get_tree().change_scene_to_file("res://Levels/riton/level_riton.tscn")

func get_visited():
	return visited

func set_visited(v: bool):
	visited = v

func save():
	return {
		"filename": get_path(),
		"visited": visited
	}
	
func load_data(save_dir):
	visited = save_dir["visited"]

func _on_hurtbox_body_exited(_body):
	island_leaved.emit("RITON")
