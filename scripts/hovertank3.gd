extends KinematicBody
const packedHit = preload("res://scenes/droneBullet1Hit.tscn")
const packedScrap = preload("res://scenes/temp test scenes/test_scrapRigidBody.tscn")
const packedBullet = preload("res://scenes/temp test scenes/test_hoverTank3Bullet.tscn")
export var scrap_value = 100
export var minDistance = 25
var nGuns = 2
var curGun = 0
var canShoot = false
var team = "enemies"
var hoverV = Vector3(0,1,0)
var tarv = Vector3(0,0,0)
export var speed = 6
export var fireRate = 0.25
var STATE = "idle"
var wepArray = []
func _ready():
	$hoverComponent.initRay($RayCast)
	$hoverComponent.connect("sendHoverV", self, "updateHoverV")
	$turretControlComponent.turret = self
	$turretControlComponent.barrel = self
	$turretTargetingComponent.connect("closestTargetPosition", self, "updateTarV")
	$turretTargetingComponent.connect("closestTargetPosition", $turretControlComponent, "setTarV")
	$basicBarrelWeaponComponent.initBarrel($wephp1, $wephp1/muzzle)
	$basicBarrelWeaponComponent2.initBarrel($wephp2, $wephp2/muzzle)
	wepArray.append($basicBarrelWeaponComponent)
	wepArray.append($basicBarrelWeaponComponent2)
	pass
func updateTarV(pv):
	tarv = pv

func updateHoverV(pV):
	hoverV = pV
func getTeam():
	return team
	
func _physics_process(delta):
	if tarv:
		if abs(global_transform.origin.distance_to(tarv)) > minDistance:
			var moveV = $heading.global_transform.origin - global_transform.origin
#			var moveV = self.global_transform.basis.z * -1
			moveV.y = hoverV.y
			moveV = moveV.normalized()
			moveV *= speed
			move_and_collide(moveV*delta)
	pass
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
func isTargetInRange(pwep):
	return abs(tarv.distance_to(global_transform.origin)) < pwep.weaponRange
func _on_brainTimer_timeout():
	if STATE != "shooting":
		if isTargetInRange($basicBarrelWeaponComponent):
			curGun = 0
			_on_shootTimer_timeout()
			$shootTimer.start(fireRate)
			STATE = "shooting"
		pass
	
	
	pass # Replace with function body.


func _on_shootTimer_timeout():
	if !isTargetInRange($basicBarrelWeaponComponent):
		STATE = "idle"
		curGun = 0
		$shootTimer.stop()
		return
	var bullet = packedBullet.instance()
	bullet.add_collision_exception_with(self)
	wepArray[curGun].fire(bullet)
	if curGun < nGuns-1:
		curGun +=1
	else:
		curGun = 0
	pass # Replace with function body.
