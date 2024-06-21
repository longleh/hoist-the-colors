class_name IniFile
extends Node

var song_name: String = ""
var song_artist: String = ""
var song_album: String = ""
var song_genre: String = ""
var song_year: String = ""
var song_difficulty: int = -1
var song_length: int = -1
var song_preview_start_time: int = -1

func parse(file: FileAccess):
	var content = file.get_as_text()
	var lines: PackedStringArray = content.split("\n")
	song_name = lines[1].rsplit(" = ", true, 1)[1]
	song_artist = lines[2].rsplit(" = ", true, 1)[1]
	song_album = lines[3].rsplit(" = ", true, 1)[1]
	song_genre = lines[4].rsplit(" = ", true, 1)[1]
	song_year = lines[5].rsplit(" = ", true, 1)[1]
	song_length = int(lines[7].rsplit(" = ", true, 1)[1])
	song_difficulty = int(lines[8].rsplit(" = ", true, 1)[1])
	song_preview_start_time = int(lines[9].rsplit(" = ", true, 1)[1])
	
func _to_string():
	return "song_name: " + song_name + "\n" + "song_artist: "+ song_artist + "\n" + "song_album: "+ song_album + "\n" + "song_genre: "+ song_genre + "\n" + "song_year: "+ song_year + "\n" + "song_difficulty: "+ str(song_difficulty) + "\n" + "song_length: "+ str(song_length) + "\n" + "song_preview_start_time: "+ str(song_preview_start_time) + "\n"
