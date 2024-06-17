extends Node2D

signal level_ended

var orc_scene = preload("res://Levels/riton/ennemies/orcs/orc.tscn")
var number_of_ennemies = 0
var number_of_pickups = 0
var score = 0
var wait_time = 255.0
@export var MAXIMUM_ENNEMIES = 300
@export var MAXIMUM_PICKUPS = 2
@onready var shandr = $YSort/Shandr
var pickups = [
	 preload("res://Levels/riton/koth/pickups/healthpack.tscn"),
]

func _ready():
	shandr.stop_movement()
	number_of_ennemies = MAXIMUM_ENNEMIES * 2
	number_of_pickups = MAXIMUM_PICKUPS * 2

func _on_mob_timer_timeout():
	if number_of_ennemies < MAXIMUM_ENNEMIES:
		# get starting pos
		var mob_spawner = $MobSpawnPath/MobSpawnerLocation
		# set a rand value to progress to have a random point of spawn
		# and use position as starting mob position
		mob_spawner.progress_ratio = randf()

		var orc = orc_scene.instantiate()
		orc.spawn(shandr.position)
		orc.set("position", mob_spawner.position)
		$YSort.add_child(orc)
		orc.connect("update_target", _update_ennemy_target)
		orc.connect("death", _on_ennemy_death)
		number_of_ennemies +=1

func _update_ennemy_target(ennemy: Node2D):
	if shandr:
		ennemy.set_target(shandr.position)
	else:
		ennemy.set_target(ennemy.position)

func _on_ennemy_death(_ennemy: Node2D):
	number_of_ennemies -= 1
	score += 1
	update_score()

func update_score():
	$Scoreboard/Score.text = str(score)

func _on_shandr_sword_hit(body):
	body.hit()

func _on_shandr_death():
	$nw_background.playing = false
	$Deathtimer.start()

func start():
	$IntroDialogue.start_dialogue()

func restart():
	var ennemies = get_tree().get_nodes_in_group("ennemies")
	for ennemy in ennemies:
		ennemy.queue_free()
	var screen_pickups = get_tree().get_nodes_in_group("pickups")
	for s_c in screen_pickups:
		s_c.queue_free()
	shandr.revive()
	shandr.position = Vector2(320, 160)
	number_of_ennemies = 0
	number_of_pickups = 0
	score = 0
	update_score()
	$PickupSpawnTimer.start()
	$UpdateTimer.start()
	$LevelTimer.start()
	$GameoverScreen.visible = false
	$nw_background.playing = true
	$deathscreen_bg.playing = false
	$MobTimer.start()
	wait_time = 255

func _on_restart_pressed():
	restart()

func _on_deathtimer_timeout():
	$Deathtimer.stop()
	$GameoverScreen.visible = true
	$deathscreen_bg.playing = true
	$PickupSpawnTimer.stop()
	$UpdateTimer.stop()
	$LevelTimer.stop()
	$MobTimer.stop()


func _on_pickup_entered(pickup):
	shandr.heal()
	pickup.queue_free()
	number_of_pickups -= 1

func _on_pickup_spawn_timer_timeout():
	if number_of_pickups < MAXIMUM_PICKUPS:
		var random_pickup = randf_range(0 ,pickups.size() - 1)
		var rand_x = randf_range(50, 590)
		var rand_y = randf_range(75, 310)
		var pickup = pickups[random_pickup].instantiate()
		pickup.position = Vector2(rand_x, rand_y)
		pickup.connect("pickup_callback", _on_pickup_entered)
		add_child(pickup)
		number_of_pickups += 1



func _on_level_timer_timeout():
	shandr.stop_movement()
	var ennemies = get_tree().get_nodes_in_group("ennemies")
	for ennemy in ennemies:
		ennemy.stop()
	$nw_background.stop()
	# * 2 in case an ennemy (or pickup) dies just before cinematic
	number_of_ennemies = MAXIMUM_ENNEMIES * 2
	number_of_pickups = MAXIMUM_PICKUPS * 2
	$IntroVictoryDialogue.start_dialogue()
	$LevelTimer.stop()


func _on_update_timer_timeout():
	# update timer laber
	wait_time -= 1.0
	var mins = 0
	var sec = 0
	if wait_time == 0:
		$LevelTimer.stop()
	if wait_time > 0:
		mins = floor(wait_time / 60)
		sec = int(floor(wait_time)) % 60
	if sec < 10:
		$Timer.text = str(mins) + ":0" + str(sec)
	else:
		$Timer.text = str(mins) + ":" + str(sec)
		

func _on_intro_victory_dialogue_dialog_end():
	$AllianceArrivalHorns.playing = true


func _on_alliance_arrival_horns_finished():
	$AllianceArrivalHorns.playing = false
	$AllianceBGSound.playing = true
	$VictoryDialogue.start_dialogue()

func end_level():
	queue_free()
	level_ended.emit()

func _on_skip_pressed():
	end_level()

func _on_victory_dialogue_dialog_end():
	$AllianceBGSound.playing = false
	end_level()


func _on_intro_dialogue_dialog_end():
	restart()
