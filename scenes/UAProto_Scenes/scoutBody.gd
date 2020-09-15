extends KinematicBody
var dir = Vector3(0,0,0)
var vel = Vector3()
var FLY_ACCEL = 6
export var MOVE_SPEED = 40
export var SPRINT_SPEED = 25
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
	add_to_group("team_blue")
	pass
func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative
	if Input.is_action_just_pressed("ui_jump"):
		dir += Vector3(0, 1, 0)
func _physics_process(delta):
	if isOccupied():
		aim()
		fly(delta)
	pass
func aim():
	if camera_change.length() > 0:
		$chassis.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))

		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$chassis/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()
func fly(delta):
	var aim = $chassis/Camera.global_transform.basis
	dir = Vector3(0,0,0)
	if Input.is_action_pressed("ui_jump"):
		dir += Vector3(0,1,0)
		sprinting = true
	if Input.is_action_pressed("ui_crouch"):
		dir += Vector3(0,-1,0)
		sprinting = true
	if Input.is_action_just_released("ui_crouch") or Input.is_action_just_released("ui_jump"):
		sprinting = false
	if Input.is_action_pressed("walk_forwards"):
		dir += aim.xform(Vector3.FORWARD)
		dir.y = 0

	if Input.is_action_pressed("walk_backwards"):
		dir += aim.xform(Vector3.BACK)
		dir.y = 0
	if Input.is_action_pressed("strafe_left"):
		dir+= aim.xform(Vector3.LEFT)
		dir.y = 0
	if Input.is_action_pressed("strafe_right"):
		dir += aim.xform(Vector3.RIGHT)
		dir.y = 0
	dir = dir.normalized()
	var speed = MOVE_SPEED
	if sprinting:
		speed += SPRINT_SPEED
	var vec = dir*speed
	
	vel = vel.linear_interpolate(vec, FLY_ACCEL*delta)
	self.move_and_slide(vel)
	pass
