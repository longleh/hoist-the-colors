extends Node2D

enum ISLANDS {
	RITON
}

@onready var islands = {
	ISLANDS.RITON: {
		"node": $RitonIsle,
		"entry_dialog": $RitonIsleStartingDiag,
	}
}
@onready var intro_path = $IntroPath/IntroPathProgress
@onready var ship = $Ship
var play_intro_scene = true
var speed = 1
var current_island = null

func _ready():
	var save_load = $Save.load_game()
	if !save_load && play_intro_scene:
		$IntroPath/IntroPathProgress/ShipIntro.stop_movement()
		ship.stop_movement()

func set_current_isle(isle: ISLANDS):
	current_island = isle

func _physics_process(delta):
	if play_intro_scene:
		intro_scene_process(delta)

func intro_scene_process(delta):
	var current_progress = intro_path.get("progress_ratio")
	var new_progress = current_progress + (speed * delta)
	if new_progress >= 1:
		intro_path.set("progress_ratio", 1)
		play_intro_scene = false
		$IntroPath/IntroPathProgress/ShipIntro.queue_free()
		add_ship(intro_path.get_parent().curve.get_closest_point(position))
		$IntroDialog.start_dialogue()
	else:
		$IntroPath/IntroPathProgress/ShipIntro.animate(Vector2(1,0))
		intro_path.set("progress_ratio", new_progress)

func _on_dialog_start():
	ship.stop_movement()

func _on_dialog_end():
	ship.resume_movement()
	if current_island && !current_island["node"].get_visited():
		current_island["node"].set_visited(true)
		$Save.save()
		current_island["node"].load_level()

func _on_isle_touched(isle_name):
	current_island = islands[ISLANDS.get(isle_name)]
	var entry_diag = current_island["entry_dialog"]
	if entry_diag && !current_island["node"].get_visited():
		entry_diag.start_dialogue()

func _on_isle_leaved(_isle_name):
	current_island = null

func save():
	var save_dict = {
		"filename": get_path(),
		"play_intro_scene": play_intro_scene,
		"ship_x": ship.position.x if ship else null,
		"ship_y": ship.position.y if ship else null,
	}
	return save_dict

func load_data(save_dir):
	play_intro_scene = save_dir["play_intro_scene"]
	if !play_intro_scene:
		$IntroPath/IntroPathProgress/ShipIntro.queue_free()
		var ship_x = save_dir["ship_x"]
		var ship_y = save_dir["ship_y"]
		var pos_vec = Vector2.ZERO
		if ship_x && ship_y:
			pos_vec = Vector2(ship_x, ship_y)
		else:
			pos_vec = Vector2(117, 0)
		add_ship(pos_vec)

func add_ship(vec: Vector2):
	ship.visible = true
	ship.set_position(vec)

func _on_left_limit_area_entered(_area):
	ship.stop_movement()
	ship.animate(Vector2(1,0))
	init_tween_on_limit(Vector2(-50, 0))
	
func init_tween_on_limit(movement_vector: Vector2):
	var tween = get_tree().create_tween()
	tween.tween_property(ship, "position", ship.get_position() - movement_vector, 0.5).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(_limit_reached_callback)

func _on_bottom_limit_body_entered(_body):
	ship.stop_movement()
	ship.animate(Vector2(0, -1))
	

func _on_up_limit_body_entered(_body):
	ship.stop_movement()
	ship.animate(Vector2(0, 1))
	init_tween_on_limit(Vector2(0, -50))
	
func _limit_reached_callback():
	ship.resume_movement()
	$LimitDialog.start_dialogue()
