extends Node2D

var orc_scene = preload("res://Levels/riton/ennemies/orcs/orc.tscn")
var number_of_ennemies = 0
@onready var shandr = $YSort/Shandr

func _on_mob_timer_timeout():
	if number_of_ennemies < 50:
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
		number_of_ennemies +=1
		

func _update_ennemy_target(ennemy: Node2D):
	if shandr:
		ennemy.set_target(shandr.position)
	else:
		ennemy.set_target(ennemy.position)


func _on_shandr_sword_hit(_body_rid, body):
	body.queue_free()
	number_of_ennemies -= 1
