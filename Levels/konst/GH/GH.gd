extends Node2D


var playing = false
var delta_sum = 0
var notes = null
var current_note_index = null
var current_bpm_index = null
var song_resolution = 480.0
var bpm = 0
var song_start_time = null
var sum_of_deltas = 1
var yy = 10
var number_of_frames = 0
var last_tick = 0
var ttw = 0
var song_playing = false

@onready var sidescroll = $Sidescroll

@onready var note_scene = preload("res://Levels/konst/GH/note/note.tscn")
@onready var color_position = {
	"0": {
		"color": Color("#008000"),
		"spawner": $Notespawner/Greenspawn
	},
	"1": {
		"color": Color("#FF0000"),
		"spawner": $Notespawner/Redspawn
	},
	"2": {
		"color": Color("#ffff00"),
		"spawner": $Notespawner/Yellowspawn
	},
	"3": {
		"color": Color("#0000ff"),
		"spawner": $Notespawner/Bluespawn
	},
	"4": {
		"color": Color("#ffa500"),
		"spawner": $Notespawner/Orangespawn
	},
	"7": {
		"color": null,
		"spawner": null
	}
}

enum {
	PARSING,
	DISPLAY_NOTE,
	WAITING,
	END
}

var note_batch = []

var current_state = PARSING

# Called when the node enters the scene tree for the first time.
func _ready():
	$GHUi/Green.toggle_mode = 1
	start()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_pressed("gh_green"):
		$GHUi/Green.set_pressed_no_signal(true)
	else:
		$GHUi/Green.set_pressed_no_signal(false)

	if playing:
		var bps = bpm / 60.0
		var factor = delta / bps
		$Sidescroll.position += Vector2(0, (240 * factor))


func _current_node_index():
	if current_note_index >= notes.size():
		current_state = END
		return -1
	return current_note_index


func start():
	$SongParser.parse()


func handle_bpm():
	var bpm_array = $SongParser.chart.bpm
	var max_size = bpm_array.size()
	if max_size <= current_bpm_index + 1:
		return
	var current_bpm = bpm_array[current_bpm_index]
	var next_bpm = bpm_array[current_bpm_index + 1]
	bpm = current_bpm["bpm"]
	var wait_time = (next_bpm["frame"] - current_bpm["frame"]) / song_resolution * 60.0 / current_bpm["bpm"]
	await get_tree().create_timer(wait_time).timeout
	current_bpm_index += 1
	handle_bpm()

func _on_song_parser_parsing_end(_s: SongParser):
	playing = true
	notes = $SongParser.chart.difficulties["MediumSingle"]
	print("ça commence ?")
	current_note_index = 0
	current_bpm_index = 0
	handle_bpm()
	handle_notes()
	#	handle_next_note()
	
	
func handle_delay():
	song_playing = true
	await get_tree().create_timer(1).timeout
	$AudioStreamPlayer2D.play()

func handle_notes():
	var index = current_note_index
	var max_size = notes.size()
	if max_size <= index:
		return
	var current_note = notes[index]
	var wait_time = (int(current_note["frame"]) - last_tick) / song_resolution * 60.0 / bpm
	if !song_playing:
		handle_delay()
	if wait_time > 0:
		await get_tree().create_timer(wait_time).timeout
	current_note_index += 1
	last_tick = int(current_note["frame"])
	spawn_note(current_note)
	handle_notes()

func spawn_note(note):
	var note_color_int = int(note["color"])
	var note_frame = int(note["frame"])
	var note_node = note_scene.instantiate()
	note_node.color(color_position[note["color"]]["color"])
	var base_position = color_position[note["color"]]["spawner"].position
	note_node.position = base_position - sidescroll.position
	$Sidescroll.add_child(note_node)
	note_node.sync()

func _on_timer_timeout():
	$Timer.stop()
