extends Node2D

signal level_ended()

func start():
	$Background.visible = true
	$BGMusic.playing = true
	$ArrivalDialogTimer.start()

func _on_arrival_dialog_timer_timeout():
	$ArrivalDialogTimer.stop()
	$ArrivalDialog.start_dialogue()

func _on_arrival_dialog_dialog_end():
	queue_free()
	level_ended.emit()
