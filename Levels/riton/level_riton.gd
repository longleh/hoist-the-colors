extends Node2D

signal island_level_ended(isle_name)

@onready var levels = [
	preload("res://Levels/riton/stormwind/Stormwind.tscn"),
	preload("res://Levels/riton/ironforge/Ironforge.tscn"),
	preload("res://Levels/riton/koth/KOTH.tscn"),
	preload("res://Levels/riton/stormwind2/stormwind2.tscn"),
]

var current_level_index = 0

func override_save():
	var save_game = FileAccess.open("user://savegame.save", FileAccess.READ_WRITE)
	var node_data = null
	while save_game.get_position() < save_game.get_length():
		var json_string = save_game.get_line()

		# Creates the helper class to interact with JSON
		var json = JSON.new()

		# Check if there is any error while parsing the JSON string, skip in case of failure
		var parse_result = json.parse(json_string)
		if not parse_result == OK:
			print("JSON Parse Error: ", json.get_error_message(), " in ", json_string, " at line ", json.get_error_line())
			continue

		# Get the data from the JSON object
		var tmp_node_data = json.get_data()
		if tmp_node_data["filename"] == "/root/World/RitonIsle":
			node_data = tmp_node_data
			node_data["visited"] = true
			save_game.store_line(JSON.stringify(node_data))
		else:
			save_game.store_line(JSON.stringify(tmp_node_data))
	if !node_data:
		node_data = {"filename": "/root/World/RitonIsle", "visited": true }
		save_game.store_line(JSON.stringify(node_data))


func play_next_level():
	if current_level_index < levels.size():
		var current_level = levels[current_level_index].instantiate()
		current_level.connect("level_ended", play_next_level)
		add_child(current_level)
		current_level.start()
		current_level_index += 1
	else:
		island_level_ended.emit("RITON")
		override_save()
		get_tree().change_scene_to_file("res://World/world.tscn")

func _on_level_ended():
	play_next_level()

func _ready():
	play_next_level()

