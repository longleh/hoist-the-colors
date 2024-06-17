class_name Dialog

extends Node

signal dialogue_start
signal dialog_end

@export_file("*.json") var dialog_file
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
var chat_index = 0
var text_displayed = false
var dialog_started = false

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
	var speaker_name = parsed_diag['chat'][chat_index]['name']
	var text = parsed_diag['chat'][chat_index]['text']
	var sprite_id = parsed_diag['chat'][chat_index]['sprite']
	var sprite_path = parsed_diag['sprites'][sprite_id] if sprite_id else null
	var position = parsed_diag['layout'][speaker_name]
	var selected_name_box = name_box[position]
	display_name_and_chat(selected_name_box, text, speaker_name)
	handle_sprite(position, sprite_path)

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

func display_name_and_chat(selected_name_box, chat_text, speaker_name):
	selected_name_box["text"].clear()
	selected_name_box["text"].add_text(speaker_name)
	chat.clear()
	chat.add_text(chat_text)
	selected_name_box["box"].visible = true
	text_displayed = true

func start_more_animation():
	continue_dialogue.visible = true
	continue_dialogue_animation.play("idle") 

func increase_index_or_end_diag():
	if chat_index + 1 < parsed_diag['chat'].size():
		chat_index += 1
		text_displayed = false
	else:
		end_dialog()

func _process(_delta):
	if !parsed_diag:
		return
	if !dialog_started:
		return
	if !text_displayed:
		return next_content()
	if text_displayed && !continue_dialogue.visible:
		return start_more_animation()
	if continue_dialogue.visible && Input.is_action_just_pressed("diag_continue"):
		return increase_index_or_end_diag()
		
func start_dialogue():
	parsed_diag = load_dialogue()
	if parsed_diag:
		dialogue_start.emit()
		dialog_started = true
		focus_background.visible = true
		base.visible = true
	else:
		end_dialog()


func end_dialog():
	dialog_end.emit()
	dialog_started = false
	focus_background.visible = false
	base.visible = false
	$RightSpriteContainer.visible = false
	$LeftSpriteContainer.visible = false
