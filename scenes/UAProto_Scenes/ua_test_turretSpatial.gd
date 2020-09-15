extends StaticBody
var canShoot = false
export var weaponRange = 400
export var aimOffset = 10
export var rateOfFire = 0.25
export var team = "team_red"
var nDebris = 10
const packedBullet = preload("res://scenes/UAProto_Scenes/ua_test_bullet.tscn")
const packedDebris = preload("res://scenes/UAProto_Scenes/redDebris.tscn")
func getTeam():
	return team
func setTeam(_team):
	team = _team
	
func _ready():
	$shootTimer.start(rateOfFire)
	$turretControlComponent.barrel = $turret/barrelPivot
	$turretControlComponent.turret = $turret
	$turretTargetingComponent.connect("closestTargetPosition",$turretControlComponent, "setTarV")
	$turretControlComponent.connect("aimIsGood",self, "readyShoot")
#	setTeam("team_red")
	add_to_group(team)
	pass
func die():
	print("I should die now...")
	var n = 0
	while n < nDebris:
		var deb = packedDebris.instance()
		FXContainer.add_child(deb)
		deb.scale *= 0.25 + randf()*2
		var pos = global_transform.origin
		pos.y = 1
		deb.global_transform.origin = pos
		var v = Vector3(rand_range(-1,1),randf(), rand_range(-1,1))
		v = v.normalized()
		v *= 50 + randi() % 100
		deb.apply_central_impulse(v) 
		n+=1
	
	queue_free()
func shoot():
	var bul = packedBullet.instance()
	$turret/barrelPivot/barrel/muzzle.add_child(bul)
	var v = $turret/barrelPivot/barrel/muzzle.global_transform.origin - $turret/barrelPivot.global_transform.origin
	bul.global_transform.origin = $turret/barrelPivot/barrel/muzzle.global_transform.origin
	bul.SPEED = 300
	v = v.normalized()
	v *= weaponRange
	v.x += rand_range(-1,1) *aimOffset
	v.y += rand_range(-1,1) *aimOffset
	v.z += rand_range(-1,1) *aimOffset
	v = v.normalized()
	v *= bul.SPEED
	bul.heading(v)
#	bul.look_at(v, Vector3.UP)
	pass
func readyShoot():
	canShoot = true

func _on_shootTimer_timeout():
	if canShoot:
		shoot()
	pass # Replace with function body.
