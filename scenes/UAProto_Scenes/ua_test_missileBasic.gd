extends KinematicBody
var armed = false
const packedDamage = preload("res://scenes/damageComponent.tscn")
func _ready():
	set_as_toplevel(true)
	$basicMissileComponent.aimer = $aimer
	$basicMissileComponent.connect("explode", self, "explode", Array(), CONNECT_ONESHOT)
	$homingComponent.connect("closestTargetPosition", $basicMissileComponent,"updateTarget")
	$basicMissileComponent.connect("arm", self, "setArmed")
	pass
func getMyWeaponComponent():
	return $basicMissileComponent


func _on_trueDeathTimer_timeout():
	queue_free()
	pass # Replace with function body.
func explode(_victim = null):
	if _victim != null:
		if _victim.is_inside_tree():
			var dm = packedDamage.instance()
			dm.initDamage(_victim, 10, "team_red")
			_victim.add_child(dm)
			print("adding damage...")
		
		
	var hit = FXContainer.packedBlueHit.instance()
	hit.amount = 15
	FXContainer.add_child(hit)
	hit.global_transform.origin = global_transform.origin
	$basicMissileComponent.hasTarget = false
	$MeshInstance.visible = false
	$CollisionShape.disabled= true
	$trueDeathTimer.start(5)
	$MotionTrail.motionDelta =10000
#	getMyWeaponComponent().queue_free()
func setArmed(_p):
	print("missile arming...")
	armed = _p

func _on_ProximityArea_body_entered(body):
	if armed:
		print("proximity explode")
		armed = false
		explode(body)
	pass # Replace with function body.
