extends KinematicBody
var camera_angle = 0
var mouseLook = true
var mouse_sensitivity = 0.3
var camera_change = Vector2()
var SPAWN_RANGE_MAX = 30
var occupied = true
var controlledDrone = null
var droneToMake = null
var creationMode = false
var justClicked = false
onready var mRay = $Head/Camera/RayCast
onready var aimer = $Head/Camera/aimer
onready var creationMenu = $Head/Camera/createMenu
enum DRONEID{
	SCOUT = 0,
	HELI
}
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	aimer.set_as_toplevel(true)
	add_to_group("team_blue")
	var menuItem = creationMenu.get_node("MenuButton").get_popup().connect("id_pressed",self, "chooseDrone")
	$constructionSpace.set_as_toplevel(true)
	pass
func beam(pPos):
	global_transform.origin = pPos
func _process(delta):
	if creationMode and !mouseLook:
		projectConstruction()
		
func _physics_process(delta):
	aim()
	if mRay.is_colliding():
		
		var v = mRay.get_collision_point()
		
		aimer.transform.origin = v
		aimer.transform.orthonormalized()
#	else:
		
		
#		aimer.set_as_toplevel(false)
func _input(event):
	if isOccupied():
		if !mouseLook and Input.is_action_just_pressed("ui_action_fire"):
			if justClicked == false:
				justClicked = true
				if creationMode:
					spawnDrone()
				$doubleClickTimer.start(1)
			elif justClicked:
				possess()
			pass
		if Input.is_action_just_pressed("ui_beam"):
			mRay.force_raycast_update()
			var pos = Vector3()
			if mRay.is_colliding():
				var colV = mRay.get_collision_point()
				if colV.distance_to(global_transform.origin) > 50:
					pos = $Head/Camera/aimer.global_transform.origin
				else:
					pos = colV
			else:
				pos = $Head/Camera/aimer.global_transform.origin
			
		if event is InputEventMouseMotion:
			camera_change = event.relative
		if Input.is_action_just_pressed("ui_secondary_fire"):
			if mouseLook:
				mouseLook = false
				Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			else: 
				mouseLook = true#toggle mouseLook on/off
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		if Input.is_action_just_pressed("ui_jump"):
			mRay.force_raycast_update()
			if mRay.is_colliding():
				var obj = mRay.get_collider()
				jumpToDrone(obj)
				
					
				
				
			
	else:
		if Input.is_action_just_pressed("ui_rtb"):
			setOccupied(true)
			mouseLook = true
func aim():
	if camera_change.length() > 0 and mouseLook:
		$Head.rotate_y(deg2rad(-camera_change.x * mouse_sensitivity))

		var change = -camera_change.y * mouse_sensitivity
		if change + camera_angle < 90 and change + camera_angle > -90:
			$Head/Camera.rotate_x(deg2rad(change))
			camera_angle += change
		camera_change = Vector2()
func isOccupied():
	return occupied
func setOccupied(toggle):
	occupied = toggle
	if occupied:
		$Head/Camera.current = true
		controlledDrone.setOccupied(false)
	else:
		$Head/Camera.clear_current()


func _on_doubleClickTimer_timeout():
	justClicked = false
	pass # Replace with function body.
func jumpToDrone(_drone):
	if _drone.has_method("setOccupied"):
		if !_drone.isOccupied():
			if !mouseLook:
				Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
				mouseLook = true
			controlledDrone = _drone
			_drone.setOccupied(true)
			self.setOccupied(false)
	pass
func projectConstruction():
	var pos2d = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera()
	var fromVec = cam.project_ray_origin(pos2d)
	var toVec = fromVec + cam.project_ray_normal(pos2d) * 50
	var space = get_world().get_direct_space_state()
	var colresult = space.intersect_ray(fromVec, toVec)
	var hitVec = Vector3()
	if !colresult.empty():
		hitVec = colresult.get("position")
		var thing = colresult.get("collider")
	else:
		hitVec = toVec
	$constructionSpace.global_transform.origin = hitVec
	pass
func spawnDrone():
	pass
func possess():
	print("JUMP INTO THING")
	var pos2d = get_viewport().get_mouse_position()
	var cam = get_viewport().get_camera()
	var fromVec = cam.project_ray_origin(pos2d)
	var toVec = fromVec + cam.project_ray_normal(pos2d) * 200
	var space = get_world().get_direct_space_state()
	var colresult = space.intersect_ray(fromVec, toVec)
	var hitVec = Vector3()
	if !colresult.empty():
		hitVec = colresult.get("position")
		var thing = colresult.get("collider")
		
		jumpToDrone(thing)
	print("hit at %s" % hitVec)
func chooseDrone(_id):
	#TODO: select drone to be created
	creationMode = true
	droneToMake = _id
	var droneName
	match _id:
		DRONEID.SCOUT:
			droneName = "Scout"
		DRONEID.HELI:
			droneName = "Heli"
	print("selected %s" % droneName)
	pass
