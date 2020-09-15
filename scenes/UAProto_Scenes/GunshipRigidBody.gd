extends RigidBody
var occupied = false
export var thrust_max = 50
export var thrust_accel = 300
var thrust_current = 0
export var TURN_SPEED = 200
var vel = Vector3()
var vv = Vector3()
var shooting = false
var canShoot = true
var tarV
onready var muzzle = $cannonMuzzle 
var packedBullet = preload("res://scenes/UAProto_Scenes/ua_test_missileBasic.tscn")
func _ready():
	add_to_group("team_blue")
	$turretTargetingComponent.targetGroup = "bot"
	var err = $turretTargetingComponent.connect("closestTargetPosition", self, "updateTargetV")
	print(err)
#	$turretTargetingComponent.connect("noTargetInRange", self, "doNoTarget")
	
	pass
func doNoTarget():
	pass
#	print("no targets")
func updateTargetV(_vt):
#	print("gunship has target")
	tarV = _vt
	if isOccupied():
		var tp = $chassis/Camera.unproject_position(_vt)
		$Control/FricOffsetLabel.text = str(tp)
		tp.x -= 32
		tp.y -= 32
		$targetLock.rect_position = tp
	pass
func isOccupied():
	return occupied
func setOccupied(toggle):
	occupied = toggle
	if occupied:
		$chassis/Camera.current = true
		$targetLock.visible = true
	else:
		$chassis/Camera.clear_current()
		$targetLock.visible = false
	pass
func _input(event):
	if Input.is_action_pressed("ui_jump") and canShoot and !shooting:
		shooting = true
		$fireTimer.start(0.5)
	if Input.is_action_just_released("ui_jump") and shooting:
		shooting = false
	pass
func _physics_process(delta):
	var vty = $chassis.global_transform.basis.y
	vty = vty.normalized()
	var vtx = $chassis.global_transform.basis.x
	vty = vty.normalized()
	var vtz = $chassis.global_transform.basis.z
	vtz = vtz.normalized()
	if isOccupied():
		if Input.is_action_pressed("walk_forwards"):
			if thrust_current + delta * thrust_accel <= thrust_max:
				thrust_current += delta * thrust_accel
		if Input.is_action_pressed("walk_backwards"):
			if thrust_current - delta * thrust_accel >= 0:
				thrust_current -= delta * thrust_accel
		if Input.is_action_pressed("strafe_left"):
			add_torque(vtz * delta*TURN_SPEED)
			pass
		if Input.is_action_pressed("strafe_right"):
			add_torque(vtz * -delta*TURN_SPEED)
		if Input.is_action_pressed("ui_left"):
			add_torque(vty * delta*TURN_SPEED)
		if Input.is_action_pressed("ui_right"):
			add_torque(vty * -delta*TURN_SPEED)
		
		if Input.is_action_pressed("ui_up"):
			add_torque(vtx * -delta * TURN_SPEED)
			pass
		if Input.is_action_pressed("ui_down"):
			add_torque(vtx * delta * TURN_SPEED)
		var vy = $chassis.global_transform.basis.y
		vy = vy.normalized()
		vy *= thrust_current
		vel = vel.linear_interpolate(vy, delta)
		apply_central_impulse(vel*delta)
#		apply_impulse(global_transform.origin,vel)
		
func getAltitude():
	return global_transform.origin.y
func getThrust():
	return thrust_current
func getDistanceX():
	var v1 = global_transform.origin
	v1.y = 0
	
	return v1.distance_to(Vector3(0,0,0))
func getSpeed():
	return self.linear_velocity.length()

func shoot(_v = null, _p = null):
	var bullet = packedBullet.instance()
	
	var v 
	v = tarV
	muzzle.add_child(bullet)
#	bullet.getMyWeaponComponent().updateTarget(v)
#	bullet.getMyWeaponComponent().hasTarget = true
#	$turretTargetingComponent.connect("closestTargetPosition", bullet.getMyWeaponComponent(), "updateTarget")
	
#	bullet.set_as_toplevel(true)
	pass
func _on_fireTimer_timeout():
	if shooting and canShoot:
		shoot()
	else:
		$fireTimer.stop()
	pass # Replace with function body.
