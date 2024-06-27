extends Node2D

var type = "PIERCE"

signal pickup_taken(type: String)

func _on_area_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	pickup_taken.emit(type)
	queue_free()

func _on_despawn_timer_timeout():
	queue_free()
