extends Node2D


var rng = RandomNumberGenerator.new()
var playing = false
var notes = null
var current_note_index = null
var current_bpm_index = null
var song_resolution = 192.0
var bpm = 0
var last_tick = 0
var song_playing = false
var in_pause = false

@onready var sidescroll = $Sidescroll

@onready var note_scene = preload("res://Levels/konst/ZombieKillingMachine/note/note.tscn")
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
@onready var player_positions = [
	$PlayerPosition/Greenspawn,
	$PlayerPosition/Redspawn,
	$PlayerPosition/Yellowspawn,
	$PlayerPosition/Bluespawn,
	$PlayerPosition/Orangespawn
]

@onready var pickups = [
	preload("res://Levels/konst/ZombieKillingMachine/pickups/FireCooldown/FireCooldown.tscn"),
	preload("res://Levels/konst/ZombieKillingMachine/pickups/ProjectilePierce/ProjectilePierce.tscn")
]

var current_player_position = 0
var score = 0

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
		$Sidescroll.position += Vector2(0, (360 * factor))

func start():
	score = 0
	update_score()
	update_stats()
	$Player.body().position = player_positions[current_player_position].position
	$Player.visible = true
	$SongParser.parse()

func update_stats():
	$Cooldown.clear()
	$Cooldown.add_text(str($Player.get_cd()))
	$Pierce.clear()
	$Pierce.add_text(str($Player.get_pierce()))

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
	if in_pause:
		await $PauseMenuOrchestrator.pause_end
	current_bpm_index += 1
	handle_bpm()

func _on_song_parser_parsing_end(_s: SongParser):
	playing = true
	notes = $SongParser.chart.difficulties["ExpertSingle"]
	current_note_index = 0
	current_bpm_index = 0
	handle_bpm()
	$AudioStreamPlayer2D.play()
	handle_notes()
	
	
func handle_delay():
	song_playing = true
	await get_tree().create_timer(1).timeout
	$AudioStreamPlayer2D.play()

func handle_notes():
	var index = current_note_index
	var max_size = notes.size()
	if max_size <= index:
		playing = false
		return
	var current_note = notes[index]
	var wait_time = (int(current_note["frame"]) - last_tick) / song_resolution * 60.0 / bpm
	if wait_time > 0:
		await get_tree().create_timer(wait_time).timeout
	if in_pause:
		await $PauseMenuOrchestrator.pause_end
	current_note_index += 1
	last_tick = int(current_note["frame"])
	spawn_note(current_note)
	handle_notes()

func spawn_note(note):
	var note_node = note_scene.instantiate()
	note_node.color(color_position[note["color"]]["color"])
	var base_position = color_position[note["color"]]["spawner"].position
	note_node.position = base_position - sidescroll.position
	note_node.connect("note_touched", _on_note_touched)
	$Sidescroll.add_child(note_node)
	note_node.sync()


func _on_note_touched(note: Node2D):
	var pickup_range = rng.randf_range(0, 100)
	if pickup_range >= 20:
		spawn_pickup(note.position)
	update_score(1)
	

func spawn_pickup(pos: Vector2):
	var pickup_index = rng.randf_range(0, pickups.size())
	var pickup = pickups[pickup_index].instantiate()
	pickup.position = pos
	pickup.connect("pickup_taken", _on_pickup_taken)
	sidescroll.call_deferred("add_child", pickup)

func _on_pickup_taken(type: String):
	$Player.improve(type)
	update_stats()

func update_score(add_value: int = 0):
	score += add_value
	$Score.clear()
	$Score.add_text(str(score))

func _on_player_move(y):
	current_player_position += y
	current_player_position = current_player_position % player_positions.size()
	$Player.body().position = player_positions[current_player_position].position


func _on_note_despawn_zone_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	update_score(-1)
