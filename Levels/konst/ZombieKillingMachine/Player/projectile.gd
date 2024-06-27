extends Node2D

enum {
	IDLE,
	GO
}

var state = IDLE

var base_velocity = Vector2(0, -360)

var pierce = 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	match state:
		GO:
			$ProjectileBody.move_and_slide()
func go(pierce_param: int = 1):
	$ProjectileBody.velocity = base_velocity
	pierce = pierce_param
	state = GO

func _on_projectile_body_body_entered(body):
	body.touched()


func _on_timer_timeout():
	queue_free()


func _on_area_2d_area_shape_entered(_area_rid, _area, _area_shape_index, _local_shape_index):
	pierce -= 1
	if pierce <= 0:
		queue_free()
