extends Node2D

enum {
	IDLE,
	GO
}

var state = IDLE

var base_velocity = Vector2(0, -360)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		GO:
			$ProjectileBody.move_and_slide()
func go():
	$ProjectileBody.velocity = base_velocity
	state = GO

func _on_projectile_body_body_entered(body):
	body.touched()


func _on_timer_timeout():
	queue_free()


func _on_area_2d_area_shape_entered(area_rid, area, area_shape_index, local_shape_index):
	queue_free()
