class_name ChartFile
extends Node

var header = {
	"toto" = 1
}

var sync_track: String = ""
var events: String = ""

var difficulties: Dictionary
var bpm: Array

var section_parsing = false

var difficulty_name: String = ""

enum SECTION {
	EVENTS,
	HEADER,
	SYNC_TRACK,
	DIFFICULTY,
	NONE
}

var _current_section: SECTION = SECTION.NONE

func parse(file: FileAccess):
	var content = file.get_as_text()
	var lines: PackedStringArray = content.split("\n")
	for line in lines:
		if line.contains("[Events]"):
			section_parsing = true
			_current_section = SECTION.NONE
		elif line.contains("[Song]"):
			section_parsing = true
			_current_section = SECTION.NONE
		elif line.contains("[SyncTrack]"):
			section_parsing = true
			_current_section = SECTION.SYNC_TRACK
		elif line.contains("{") && section_parsing:
			continue
		elif line.contains("}") && section_parsing:
			section_parsing = false
			difficulty_name = ""
			_current_section = SECTION.NONE
		elif section_parsing:
			match _current_section: 
				SECTION.DIFFICULTY:
					parse_difficulty(line)
				SECTION.SYNC_TRACK:
					parse_sync_track(line)
		else:
			difficulty_name = line.replace("[", "").replace("]", "").replace("\r", "")
			difficulties[difficulty_name] = []
			_current_section = SECTION.DIFFICULTY
			section_parsing = true

func parse_difficulty(line):
	var note_line = line.replace("\r", "").split(' = ')
	var note_frame = note_line[0]
	var note_deep = note_line[1].split(" ")
	if note_deep[0].contains("N") && note_deep.size() > 2:
		var note_color = note_deep[1]
		var note_length = note_deep[2]
		if int(note_color) <= 4:
			difficulties[difficulty_name].append({
			"frame": note_frame,
			"color": note_color,
			"note_length": note_length
			})

func parse_sync_track(line):
		# [SyncTrack]
# {
  #0 = TS 4
  #0 = B 214300
  #1536 = B 216000
	var note_line = line.replace("\r", "").split(' = ')
	var note_frame = note_line[0]
	var note_deep = note_line[1].split(" ")
	if note_deep[0].contains("B") && note_deep.size() > 1:
		bpm.append({
			"frame": int(note_frame),
			"bpm": float(note_deep[1]) / 1000
		})
