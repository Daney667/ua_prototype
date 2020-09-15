extends KinematicBody
var hoverV = Vector3(0,0,0)

var moveTargetPos
var v1
var v2
var STATE
var tarpos
var fireV
var curGun = 1
var nGuns = 2
export var minDistanceToTarget = 25
export var team = "enemies"
export var fireDistance = 70
export var aim_offset = 2
export var move_speed = 12
export var turn_speed = 2
export var scrap_value = 50
var haveTarget
var targetV
var canShoot = false
onready var ray = $RayCast
const packedBullet = preload("res://scenes/drone3Bullet.tscn")
const packedSparks = preload("res://scenes/drone3Sparks.tscn")
const packedScrap = preload("res://scenes/temp test scenes/test_scrapRigidBody.tscn")
func _ready():
	STATE = "idle"
	$turretTargetingComponent.connect("closestTargetPosition", self, "updateTar")
	add_to_group("enemies")
	$hoverComponent.connect("sendHoverV", self, "updateHoverV")
	$hoverComponent.initRay($RayCast)
	pass
func getTeam():
	return team
func updateTar(v):
	v1 = v
	pass
func updateHoverV(pV):
	hoverV = pV
func die():
	var nscrapPieces = randi() % 4 + 2
	var n = 0
	while n < nscrapPieces:
		var scrp = packedScrap.instance()
		FXContainer.add_child(scrp)
		scrp.scrap_value = scrap_value/nscrapPieces
		scrp.add_collision_exception_with(self)
		scrp.global_transform.origin = global_transform.origin
		n+= 1
	queue_free()
func _physics_process(delta):
	if v1 != null:
		v1.y += 1
		v2 = v1
		v1.x += rand_range(-1,1)*aim_offset
		v1.z += rand_range(-1,1)*aim_offset
				
		var lookPos = v2
		var goalLookPos = v2
		var goalTrans = Transform()
		goalTrans.origin = global_transform.origin
		
		goalTrans = goalTrans.looking_at(goalLookPos,Vector3.UP)
		global_transform = global_transform.interpolate_with(goalTrans, delta * turn_speed)
		tarpos = v1
		if STATE == "charge":
	#			moveTargetPos = (lookPos - global_transform.origin).normalized()
			moveTargetPos = global_transform.basis.z.normalized() * -1
			moveTargetPos.y = hoverV.y
			moveTargetPos = moveTargetPos.normalized()
			moveTargetPos *= move_speed
			move_and_slide(moveTargetPos)
		if global_transform.origin.distance_to(lookPos) > minDistanceToTarget:
			STATE = "charge"
		if global_transform.origin.distance_to(tarpos) < fireDistance:
			canShoot = true
			targetV = (tarpos - global_transform.origin)
		else:
			canShoot = false
		if global_transform.origin.distance_to(lookPos) <= minDistanceToTarget:
			STATE = "idle"
	pass


func _on_shootTimer_timeout():
	if canShoot:
		if curGun < nGuns:
			curGun += 1
		else:
			curGun = 1
#		print("bang from gun # %s" % (curGun))
		var bullet = packedBullet.instance()
		FXContainer.add_child(bullet)
		bullet.add_collision_exception_with(self)
		var sparks = packedSparks.instance()
		
		if curGun == 1:
			bullet.global_transform.origin = $muzzleHardpoint.global_transform.origin
			$muzzleHardpoint.add_child(sparks)
		else:
			bullet.global_transform.origin = $muzzleHardpoint2.global_transform.origin
			$muzzleHardpoint2.add_child(sparks)
		bullet.sparks = packedSparks
		sparks.emitting = true
		fireV = $muzzleHardpoint/muzzleHelper.global_transform.origin - $muzzleHardpoint.global_transform.origin
		fireV = fireV.normalized()
		fireV *= minDistanceToTarget
		fireV.x += rand_range(-1,1) * aim_offset
		fireV.y += rand_range(-1,1) * aim_offset
		fireV.z += rand_range(-1,1) * aim_offset
		fireV = fireV.normalized()
		bullet.setHeading(fireV)
	pass # Replace with function body.
