extends KinematicBody
var occupied
export var team = "team_blue" 
var targetBasis = Basis()
var camera_change = Vector2()
var mouse_sensitivity = 0.2
var camera_angle = 0
var dir = Vector3()
var vel = Vector3()
var top_speed = 60
const FLY_ACCEL = 1
const TURN_ACCEL = 0.06
var mpackedBullet = FXContainer.packedRedBullet
var packedBlood = FXContainer.packedBlueHit
var shooting = false
var canShoot = true
var wcv
export var gunRate = 0.3
onready var barrel = $chassis_rotationHelper/chassis/gunbase
onready var muzzle = $chassis_rotationHelper/chassis/muzzle
onready var wepRay = $chassis_rotationHelper/chassis/RayCast
onready var camRay = $rotationHelper/Camera/RayCast
func _ready():
	$rotationHelper/Camera/centerCrosshair.margin_right = get_viewport().size.x
	$rotationHelper/Camera/centerCrosshair.margin_bottom = get_viewport().size.y
	$aimerMesh.set_as_toplevel(true)
	add_to_group("team_blue")
	targetBasis = global_transform.basis
	camRay.add_exception(self)
	pass
func isOccupied():
	return occupied
func setOccupied(toggle):
	occupied = toggle
	if occupied:
		$rotationHelper/Camera/centerCrosshair.visible = true
		$rotationHelper/Camera.current = true
	else:
		$rotationHelper/Camera/centerCrosshair.visible = false
		$rotationHelper/Camera.clear_current()
	pass
func getTeam():
	return team

func aim():
	if camera_change.length() > 0:
		$rotationHelper.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))

		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$rotationHelper/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()
func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative
	if Input.is_action_pressed("ui_action_fire") and !shooting and canShoot:
		shooting = true
		$shootTimer.start(gunRate)
	if Input.is_action_just_released("ui_action_fire") and shooting:
		shooting = false
	pass
func _physics_process(delta):
	if isOccupied():
		aim()
		fly(delta)
		wcv = $rotationHelper/Camera.unproject_position($aimerMesh.global_transform.origin)
		wcv.x -= 32
		wcv.y -= 32
		$rotationHelper/Camera/weaponCrosshair.rect_position =wcv
	if wepRay.is_colliding():
		$rotationHelper/Camera/weaponCrosshair.visible =true
		var rv = wepRay.get_collision_point()
		$aimerMesh.global_transform.origin = rv
	else:
#		$aimerMesh.global_transform.origin = $chassis_rotationHelper/pointer.global_transform.origin + 
		$rotationHelper/Camera/weaponCrosshair.visible =false
		pass
	pass
func fly(delta):
	camRay.force_raycast_update()
	var camRayVec = Vector3()
	if camRay.is_colliding():
		camRayVec = camRay.get_collision_point()
	else:
		camRayVec = $rotationHelper/Camera.global_transform.origin + $rotationHelper/Camera.global_transform.basis.z.normalized()*-200
	$chassis_rotationHelper/pointer.look_at(camRayVec, Vector3.UP)
	var tarTrans = Transform()
	tarTrans = $chassis_rotationHelper/pointer.global_transform
	$chassis_rotationHelper/chassis.global_transform = $chassis_rotationHelper/chassis.global_transform.interpolate_with(tarTrans, delta*top_speed*TURN_ACCEL)
	var aim = $chassis_rotationHelper/chassis.global_transform.basis
	dir = Vector3(0,0,0)
	if Input.is_action_pressed("walk_forwards"):
		var fv = aim.z
		fv.y = 0
		dir -= fv
	if Input.is_action_pressed("walk_backwards"):
		var bv = aim.z
		bv.y = 0
		dir += bv
	if Input.is_action_pressed("strafe_left"):
		dir -= aim.x
	if Input.is_action_pressed("strafe_right"):
		dir += aim.x
	if Input.is_action_pressed("ui_jump"):
		dir += Vector3(0,1,0)
	if Input.is_action_pressed("ui_crouch"):
		dir -= Vector3(0,1,0)
	dir = dir.normalized()
	var vec = dir * top_speed
	vel = vel.linear_interpolate(vec, delta * FLY_ACCEL)
	self.move_and_slide(vel)
	pass
func shoot(_vec, _pos):
	var bullet = mpackedBullet.instance()
	if bullet.has_method("setTeam"):
		bullet.setTeam("team_blue")
#	FXContainer.add_child(bullet)
#	bullet.global_transform.origin = muzzle.global_transform.origin
#	bullet.look_at($chassis_rotationHelper/chassis/muzzle2.global_transform.origin, Vector3.UP)
	muzzle.add_child(bullet)
	bullet.heading(_vec)
	bullet.set_as_toplevel(true)
	bullet.DAMAGE = 10
	pass

func getBlood():
	return packedBlood

func _on_shootTimer_timeout():
	if canShoot and shooting:
		var v = muzzle.global_transform.origin - barrel.global_transform.origin
		v = v.normalized()
		
		v *= 500
		var p = muzzle.global_transform.origin
		shoot(v, p)
	else:
		$shootTimer.stop()
	pass # Replace with function body.
