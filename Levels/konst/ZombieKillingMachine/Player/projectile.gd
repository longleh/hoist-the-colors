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
