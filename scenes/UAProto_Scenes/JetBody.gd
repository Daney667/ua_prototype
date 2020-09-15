extends KinematicBody
var dirQ = Quat()
var vel = Vector3()
var FLY_ACCEL = 100
var grav = 9.8
var fric = 0.1
export var mass = 5
export var MOVE_SPEED_MAX = 60
export var TURN_SPEED = 1
var move_speed_current = 0
export var SPRINT_SPEED = 5
var sprinting = false 
var camera_change = Vector2()
var mouse_sensitivity = 0.2
var camera_angle = 0
var occupied = false
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
	pass
func _input(event):
	pass
func _physics_process(delta):
#	if isOccupied():
	fly(delta)
	pass

func fly(delta):
	
	var t = Basis()
	t = self.global_transform.basis
	var vy = $chassis.global_transform.basis.y
	vy = vy.normalized()
	var vx = $chassis.global_transform.basis.x
	vx = vx.normalized()
	var vz = $chassis.global_transform.basis.z
	vz = vz.normalized()
#	var vrx = vx
#	var vry = vy
#	var vrz = vz
	
	if isOccupied():
	#PITCH
		if Input.is_action_pressed("ui_down"):
			rotate(vx, -delta*TURN_SPEED)
		if Input.is_action_pressed("ui_up"):
			rotate(vx, delta*TURN_SPEED)
	#YAW
#		if Input.is_action_pressed("ui_heli_roll_left"):
#			rotate(vy, delta*TURN_SPEED*0.25)
#		if Input.is_action_pressed("ui_heli_roll_right"):
#			rotate(vy, -delta*TURN_SPEED*0.25)
	#ROLL
		if Input.is_action_pressed("ui_left"):
			rotate(vz, -delta*TURN_SPEED)
		if Input.is_action_pressed("ui_right"):
			rotate(vz, delta*TURN_SPEED)
	#POWER/THRUST "ROTOR SPEED"
		if Input.is_action_pressed("ui_jump"):
			if move_speed_current < MOVE_SPEED_MAX+(FLY_ACCEL*delta):
				move_speed_current += FLY_ACCEL*delta
		if Input.is_action_pressed("ui_crouch"):
			if move_speed_current - (FLY_ACCEL*delta) > 0:
				move_speed_current-= FLY_ACCEL*delta
#			else:
#				move_speed_current = 0
#	t = t.orthonormalized()
	
	var vv = global_transform.basis.z
	vv.normalized()
#	global_transform.basis = t
	vv *= move_speed_current
	vv.y += -grav
	
#	vv*=mass
	vel = vel.linear_interpolate(vv, delta)
	move_and_collide(vel*delta)
#	move_and_slide(vel,Vector3(0,1,0),true,3,45,false)


	pass
