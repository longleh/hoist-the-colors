class_name SongParser
extends Node

signal parsing_end(s: SongParser)

@export_dir var song_directory

var _chart_file: FileAccess = null
var _ini_file: FileAccess = null
@onready var ini : IniFile = $IniFile
@onready var chart : ChartFile = $ChartFile

func parse():
	print("ICI")
	var dir = DirAccess.open(song_directory)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".chart"):
				_chart_file = FileAccess.open(song_directory + "/" + file_name, FileAccess.READ)
			elif file_name.ends_with(".ini"):
				_ini_file = FileAccess.open(song_directory + "/" + file_name, FileAccess.READ)
			if _ini_file && _chart_file:
				break
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	if !_ini_file || !_chart_file:
		printerr("No ini or chart file found in folder")
	ini.parse(_ini_file)
	_ini_file.close()
	chart.parse(_chart_file)
	_chart_file.close()
	parsing_end.emit(self)

