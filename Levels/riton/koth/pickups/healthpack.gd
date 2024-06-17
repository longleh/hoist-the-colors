extends Area2D

signal pickup_callback(pickup: Node2D)

# Called when the node enters the scene tree for the first time.
func _ready():
	$AnimationPlayer.play("idle")


func _on_body_shape_entered(_body_rid, _body, _body_shape_index, _local_shape_index):
	pickup_callback.emit(self)
