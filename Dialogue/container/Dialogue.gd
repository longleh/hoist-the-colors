class_name Dialog

extends Node

signal dialogue_start
signal dialog_end

@export_file("*.json") var dialog_file
@export_range(0.0, 1.0) var DELTA_THRESHOLD = 0.01
@export var INSTANT_DIALOG: bool = false

@onready var base = $Base
@onready var chat = $Base/Chat/Chat
@onready var continue_dialogue = $Base/ContinueDialog
@onready var continue_dialogue_animation = $Base/ContinueDialog/AnimationPlayer
@onready var focus_background = $FocusBackgroundContainer

@onready var name_box = {
	"left": {
		"box": $Base/NameLeft,
		"text": $Base/NameLeft/Name,
	},
	"right": {
		"box": $Base/NameRight,
		"text": $Base/NameRight/Name,
	}
}
@onready var sprites = {
	"left": {
		"container": $LeftSpriteContainer,
		"sprite": $LeftSpriteContainer/LeftSprite
	},
	"right": {
		"container": $RightSpriteContainer,
		"sprite": $RightSpriteContainer/RightSprite
	}
}

var parsed_diag = null
var line_index = 0
var text_to_display = null
var text_index = 0
var sum_of_deltas = 0

enum D_STATE {
	HOLD,
	STOPPED,
	STARTED,
	GET_NEXT_LINE,
	DISPLAY_CHAT,
	ENDED,
}

var CURRENT_STATE: D_STATE = D_STATE.HOLD

func load_dialogue():
	if FileAccess.file_exists(dialog_file):
		var file = FileAccess.open(dialog_file, FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())
		file.close()
		return content
	else:
		return null

func next_content():
	hide_name_box()
	var speaker_name = parsed_diag['chat'][line_index]['name']
	text_to_display = parsed_diag['chat'][line_index]['text']
	text_index = 0
	chat.clear()
	var sprite_id = parsed_diag['chat'][line_index]['sprite']
	var sprite_path = parsed_diag['sprites'][sprite_id] if sprite_id else null
	var position = parsed_diag['layout'][speaker_name]
	var selected_name_box = name_box[position]
	display_name(selected_name_box, speaker_name)
	handle_sprite(position, sprite_path)
	CURRENT_STATE = D_STATE.DISPLAY_CHAT

func handle_sprite(position, sprite_path):
	sprites["left"]["container"].set("layer", 1)
	sprites["right"]["container"].set("layer", 1)
	sprites[position]["container"].set("layer", 2)
	if sprite_path:
		var texture = load(sprite_path)
		sprites[position]["sprite"].set("texture", texture)
		sprites[position]["sprite"].visible = true
	else:
		sprites[position]["sprite"].visible = false

func hide_name_box():
	name_box["left"]["box"].visible = false
	name_box["right"]["box"].visible = false

func display_name(selected_name_box, speaker_name):
	selected_name_box["text"].clear()
	selected_name_box["text"].add_text(speaker_name)
	selected_name_box["box"].visible = true

func start_more_animation():
	continue_dialogue.visible = true
	continue_dialogue_animation.play("idle") 

func increase_index_or_end_diag():
	if line_index + 1 < parsed_diag['chat'].size():
		line_index += 1
	else:
		CURRENT_STATE = D_STATE.STOPPED

func _process(delta):
	match CURRENT_STATE:
		D_STATE.STARTED:
			next_content()
		D_STATE.STOPPED:
			if !continue_dialogue.visible:
				start_more_animation()
			elif Input.is_action_just_pressed("diag_continue"):
				end_dialog()
		D_STATE.GET_NEXT_LINE:
			if !continue_dialogue.visible:
				start_more_animation()
			elif Input.is_action_just_pressed("diag_continue"):
				next_content()
		D_STATE.DISPLAY_CHAT:
			sum_of_deltas += delta
			if sum_of_deltas >= DELTA_THRESHOLD || is_fasting_diag():
				display_chat()
				sum_of_deltas = 0

func is_fasting_diag() -> bool:
	if Input.is_action_pressed("diag_continue"):
		return true
	return false

func display_chat():
	if INSTANT_DIALOG:
		chat.add_text(text_to_display)
		line_displayed()
	elif text_index >= text_to_display.length():
		line_displayed()
	else:
		chat.add_text(text_to_display[text_index])
		text_index += 1

func line_displayed():
	CURRENT_STATE = D_STATE.GET_NEXT_LINE
	text_index = 0
	text_to_display = null
	increase_index_or_end_diag()

func start_dialogue():
	parsed_diag = load_dialogue()
	if parsed_diag:
		dialogue_start.emit()
		focus_background.visible = true
		base.visible = true
		CURRENT_STATE = D_STATE.STARTED
	else:
		CURRENT_STATE = D_STATE.STOPPED
		end_dialog()


func end_dialog():
	dialog_end.emit()
	focus_background.visible = false
	base.visible = false
	$RightSpriteContainer.visible = false
	$LeftSpriteContainer.visible = false
	CURRENT_STATE = D_STATE.ENDED
