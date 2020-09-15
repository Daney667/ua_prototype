extends VehicleBody
var occupied = false
func isOccupied():
	return occupied
func setOccupied(toggle):
	occupied = toggle
	if occupied:
		$Camera.current = true
	else:
		$Camera.clear_current()
	pass
func _ready():
	pass
func _input(event):
	if Input.is_action_pressed("walk_forwards"):
		engine_force += 10
	if Input.is_action_pressed("walk_backwards"):
		engine_force -= 10
	if Input.is_action_just_pressed("strafe_left"):
		steering -= 2
	if Input.is_action_just_pressed("strafe_right"):
		steering += 2
