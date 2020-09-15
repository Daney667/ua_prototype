extends KinematicBody
var dirQ = Quat()
var vel = Vector3()
var vrx = Vector3()
var vry = Vector3()
var vrz = Vector3()
var rt = Transform()
var rangeToOrigin
var FLY_ACCEL = 100
var grav = 9.8
var fric = 0.0001
export var mass = 10
export var MOVE_SPEED_MAX = 60
export var TURN_SPEED = 1.0
var turn_accel = 0
export var MAX_HEIGHT = 200
var move_speed_current = 0
export var SPRINT_SPEED = 5
var sprinting = false 
var camera_change = Vector2()
var mouse_sensitivity = 0.2
var camera_angle = 0
var occupied = false
var grounded = false
var tarBasis
func isOccupied():
	return occupied
func setOccupied(toggle):
	occupied = toggle
	if occupied:
		$chassis/Camera.current = true
		
	else:
		$chassis/Camera.clear_current()
	pass
func _ready():
	add_to_group("team_blue")
	
	pass
func _input(event):
	
	pass
func _physics_process(delta):

#	if isOccupied():

	fly(delta)
	pass

func fly(delta):
#	$Control/AccelLabel.text = "THRUST: %s" %str(move_speed_current)

#	var vy = $chassis.global_transform.origin - $chassis/Position3D.global_transform.origin
	var vy = $chassis.global_transform.basis.y
	vy = vy.normalized()
	var vx = $chassis.global_transform.basis.x
	vx = vx.normalized()
	var vz = $chassis.global_transform.basis.z
	vz = vz.normalized()

	var curQ = Quat()
	var finalQ = Quat()
	tarBasis = global_transform.basis
	var tarQ = tarBasis.get_rotation_quat()
	
	if isOccupied():
		if not grounded:
		#PITCH
			if Input.is_action_pressed("ui_down"):
				turn_accel += TURN_SPEED*delta
				finalQ = tarBasis.rotated(vx, -TURN_SPEED).get_rotation_quat()
#				tarQ = tarQ.slerp(finalQ,1)
				tarBasis = Basis(finalQ)
#				tarBasis = tarBasis.slerp(finalBasis, delta)
#				tarBasis = tarBasis.rotated(vx, -TURN_SPEED)
#				rotate(vx, -delta*TURN_SPEED)
			if Input.is_action_pressed("ui_up"):
#				rotate(vx, delta*TURN_SPEED)
				tarBasis = tarBasis.rotated(vx, TURN_SPEED)
		#YAW
			if Input.is_action_pressed("ui_left"):
				tarBasis = tarBasis.rotated(vy, TURN_SPEED)
#				rotate(vy, delta*TURN_SPEED)
			if Input.is_action_pressed("ui_right"):
				tarBasis = tarBasis.rotated(vy, -TURN_SPEED)
#				rotate(vy, -delta*TURN_SPEED)
		#ROLL
			if Input.is_action_pressed("ui_heli_roll_left"):
				tarBasis = tarBasis.rotated(vz, -TURN_SPEED)
#				rotate(vz, -delta*TURN_SPEED)
			if Input.is_action_pressed("ui_heli_roll_right"):
				tarBasis = tarBasis.rotated(vz, TURN_SPEED)
#				rotate(vz, delta*TURN_SPEED)
#			if turn_accel > 0 :
#				turn_accel -= delta
	#POWER/THRUST "ROTOR SPEED"
		
		if Input.is_action_pressed("ui_jump"):
			if move_speed_current < MOVE_SPEED_MAX+(FLY_ACCEL*delta):
				move_speed_current += FLY_ACCEL*delta
		if Input.is_action_pressed("ui_crouch"):
			if move_speed_current - (FLY_ACCEL*delta) > 0:
				move_speed_current-= FLY_ACCEL*delta
#	var finalTrans = Transform(tarBasis, global_transform.origin)
	var finalBasis = global_transform.basis
	finalBasis = finalBasis.orthonormalized()
	
	finalBasis = finalBasis.slerp(tarBasis,delta*TURN_SPEED)
	
	global_transform.basis = finalBasis
	var vv = global_transform.basis.y
	vv.normalized()
	var vb = vv
	vv *= move_speed_current
	
	vv.y += -grav*grav
	var alt = global_transform.origin.y
	var hvoff = move_speed_current * (alt/MAX_HEIGHT)*0.5
	var offsetVel = move_speed_current - hvoff
	offsetVel = clamp(offsetVel,0,move_speed_current)
#	var fricOffset = fric*(vv.length_squared())
	vb *= offsetVel #- fricOffset

	vb.y += -grav*grav
	vel = vel.linear_interpolate(vb, delta)

	if not grounded:
		move_and_collide(vel*delta)
	if $groundRay.is_colliding() and move_speed_current < 4:
		grounded = true
	else:
		grounded = false
			
	if grounded and $groundRay.is_colliding() != true:
		grounded = false
	
	

	pass
func doGround():
	pass
func setBasis(pBasis):
	pBasis.orthonormalized()
	global_transform.basis = pBasis
func getAltitude():
	return global_transform.origin.y
func getThrust():
	return move_speed_current
func getDistanceX():
	return abs(global_transform.origin.x)
