extends KinematicBody

export var springiness = 0.8
var curLen
var targetLen
var falling = false
onready var ray = $RayCast
export var hover_height = 4
var readyToFireMain = false
var mainGunOpen = false
var STATE = "idle"
var canShoot = false
var moveTargetV = Vector3(0,0,0)
export var move_speed = 3
export var minDistance = 100
onready var myTurret = $chassis/turret
onready var myBarrel = $chassis/turret/barrelBase
onready var myMuzzle = $chassis/turret/barrelBase/barrel/main_muzzleHardpoint
onready var myBarrel2 = $chassis/turret/barrelBase/barrel
const packedBullet = preload("res://scenes/tank2Shell.tscn")
onready var packedSparks = preload("res://scenes/tank2sparks.tscn")

func _ready():
	add_to_group("enemies")
	$turretTargetingComponent.connect("closestTargetPosition", $turretControlComponent, "setTarV" )
	$turretTargetingComponent.connect("closestTargetPosition", self, "on_target_postion_update")
	$turretTargetingComponent.connect("noTargetInRange", self, "on_no_target")
	$turretControlComponent.turret = myTurret
	$turretControlComponent.barrel = $chassis/turret/barrelBase
	$chassisControlComponent2.turret = self
	$turretTargetingComponent.connect("closestTargetPosition", $chassisControlComponent2, "setTarV" )
	_on_brainTimer_timeout()
	pass

func _physics_process(delta):
	
	if STATE != "idle":
		move_towards_point()

func on_target_postion_update(pMoveTargetV):
	moveTargetV = pMoveTargetV
	pass
func prepMainGun():
	$AnimationPlayer.play("openMainGunAction")
func fireMainGun():
	
	if readyToFireMain and mainGunOpen:
		
		$AnimationPlayer.play("fireMainGunAction")
#		DO: projectile spawn
		readyToFireMain = false
	pass
func move_towards_point():
	var v = Vector3(0,0,0)
	ray.force_raycast_update()
	var diff
	if ray.is_colliding():
		curLen = (ray.global_transform.origin - ray.get_collision_point()).length()
		diff = (hover_height - curLen)
		if curLen < hover_height:
			falling = false
			v = Vector3(0, diff,0)
		if curLen > hover_height:
#			falling or gliding?
			falling = true
			v = Vector3(0,diff,0)
	var dv = $rotationHelper/Position3D.global_transform.origin - global_transform.origin
	dv.y = v.y
	if moveTargetV.distance_to(global_transform.origin) > minDistance:
		move_and_slide(dv.normalized() * move_speed, Vector3.UP)
	pass
func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "openMainGunAction":
		mainGunOpen = true
		readyToFireMain = true
		STATE = "ready with main"
		pass
	if anim_name == "closeMainGunAction":
		STATE = "idle"
		mainGunOpen = false
	pass # Replace with function body.

func shoot():
#	print("BANG")
	print($turretControlComponent.mScale)
	if readyToFireMain:
		var sparks = packedSparks.instance()
		var bullet = packedBullet.instance()
		FXContainer.add_child(bullet)
		myMuzzle.add_child(sparks)
		sparks.emitting = true
		bullet.add_collision_exception_with(self)
		bullet.global_transform.origin = myMuzzle.global_transform.origin
		var tarv = myMuzzle.global_transform.origin - myBarrel2.global_transform.origin
		
		bullet.heading(tarv)
		bullet.look_at(moveTargetV, Vector3.UP)
	pass
func on_no_target():
	if STATE != "notarget":
		STATE = "notarget"
		readyToFireMain = false
		
func _on_brainTimer_timeout():
	if STATE == "idle":
		if mainGunOpen == false:
			prepMainGun()
			STATE = "prepping main"
	if STATE == "ready with main":
		STATE = "targeting"
		$turretTargetingComponent.targetClosest()
	
	if STATE == "notarget":
		$AnimationPlayer.play("closeMainGunAction")
		STATE = "closing main"
	print("Tank is ...%s" % STATE)
	pass # Replace with function body.
func die():
	remove_from_group("enemies")
	queue_free()


func _on_fireTimer_timeout():
	if STATE == "targeting":
		$AnimationPlayer.play("fireMainGunAction")
		shoot()
	pass # Replace with function body.
