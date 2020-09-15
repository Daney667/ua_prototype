extends RigidBody

var mv
var collision
func _ready():
	mv = Vector3(rand_range(-30,30), rand_range(1,30), rand_range(-30,30))
	apply_central_impulse(mv)
	pass # Replace with function body.

func _physics_process(delta):
#	mv.y *= -9.81*delta
#	collision = move_and_collide(mv * delta)
	pass
