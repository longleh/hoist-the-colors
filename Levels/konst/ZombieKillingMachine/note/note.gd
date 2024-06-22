extends Node2D

# Called when the node enters the scene tree for the first time.
func color(new_color):
	$StaticBody2D/Color.color = new_color

func sync():
	$Timer.start()

func _on_timer_timeout():
	queue_free()

func touched():
	queue_free()

func _on_touched(_area_rid, _area, _area_shape_index, _local_shape_index):
	queue_free()
