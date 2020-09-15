extends KinematicBody

var occupied = false
export var team = "team_blue" 
var targetBasis = Basis()
var tarRotX = Transform()
var camera_change = Vector2()
var mouse_sensitivity = 0.2
var camera_angle = 0
var shooting = false
var canShoot = true
var unlockedRotation = false
var barrelrestZ 
var barrelRestTrans = Transform()
var maxBarrelAngle = 10
# Called when the node enters the scene tree for the first time.
func _ready():
	add_to_group("team_blue")
	barrelrestZ = $turretMesh/barrelMesh.transform.basis.z
	barrelRestTrans = $turretMesh/barrelMesh.transform
	$turretMesh/opticSensorSphere.set_as_toplevel(true)
	$turretMesh/barrelMesh/muzzle/gunPointer.set_as_toplevel(true)
	tarRotX = $turretMesh/barrelMesh.transform
	pass # Replace with function body.
func _physics_process(delta):
	$turretMesh/opticSensorSphere.global_transform.origin = $turretMesh/sensorBase.global_transform.origin
	if occupied:
		aim(delta)
		if $turretMesh/barrelMesh/muzzle/RayCast.is_colliding():
			$turretMesh/barrelMesh/muzzle/gunPointer.global_transform.origin = $turretMesh/barrelMesh/muzzle/RayCast.get_collision_point()
		else:
			$turretMesh/barrelMesh/muzzle/gunPointer.global_transform.origin = $turretMesh/barrelMesh/muzzle.global_transform.origin + $turretMesh/barrelMesh/muzzle.global_transform.basis.z*-100
func aim(delta):
	var barrelCurZ = $turretMesh/barrelMesh.transform.basis.z
	var ang = (acos(barrelrestZ.dot(tarRotX.basis.z)))
	var goalTrans
	if camera_change.length() > 0:
		$turretMesh/opticSensorSphere.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))
		
		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90 :
			tarRotX = tarRotX.rotated(Vector3.RIGHT, change*delta)
			tarRotX = tarRotX.orthonormalized()
			
			camera_angle += change
		camera_change = Vector2()
#	print(tarRotX.basis.z.cross(barrelrestZ).x)
	if rad2deg(ang) < maxBarrelAngle:
		goalTrans = tarRotX
	else:
		goalTrans = tarRotX
		var side = sign(tarRotX.basis.z.cross(barrelrestZ).x)
		if side <= 0:
			goalTrans = barrelRestTrans.rotated(Vector3(1,0,0), deg2rad(maxBarrelAngle))
		else:
			goalTrans = barrelRestTrans.rotated(Vector3(1,0,0), deg2rad(-maxBarrelAngle))
	$turretMesh/barrelMesh.transform = $turretMesh/barrelMesh.transform.interpolate_with(goalTrans,delta*4)
	$pointer.rotation = $turretMesh/opticSensorSphere.rotation
	var tarTrans = $pointer.transform
	$turretMesh.transform = $turretMesh.transform.interpolate_with(tarTrans,delta*2) 
func _input(event):
	if event is InputEventMouseMotion:
		camera_change = event.relative
	if Input.is_action_pressed("ui_action_fire") and !shooting and canShoot:
		shooting = true
#		$shootTimer.start(gunRate)
	if Input.is_action_just_released("ui_action_fire") and shooting:
		shooting = false
	pass

func isOccupied():
	return occupied
func setOccupied(toggle):
	occupied = toggle
	if occupied:
		$turretMesh/opticSensorSphere/Camera.current = true
	else:
		$turretMesh/opticSensorSphere/Camera.clear_current()
	pass
func getTeam():
	return team
