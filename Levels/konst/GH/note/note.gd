extends Node2D

# Called when the node enters the scene tree for the first time.
func color(new_color):
	$StaticBody2D/Color.color = new_color

func _process(delta):
	pass

func sync():
	$Timer.start()

func _on_timer_timeout():
	queue_free()
