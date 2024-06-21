extends Node2D

signal island_touched(isle_name)
signal island_leaved(isle_name)

var visited = false

func _on_area_2d_body_entered(_body):
	island_touched.emit("KONST")

func load_level():
	get_tree().change_scene_to_file("res://Levels/konst/konst_level.tscn")

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
	island_leaved.emit("KONST")
