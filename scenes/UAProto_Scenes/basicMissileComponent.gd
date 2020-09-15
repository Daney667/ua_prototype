extends Node
var boss
var aimer
var v3
var hasTarget
var max_turnspeed = 1
var turnspeed = max_turnspeed
var max_speed = 150
var accel = 1
var speed = 25

var curStage = null
var stage1 = { speed = 50,
				fuel = 0.5,
				homing = false,
				turn_speed = 1}
var stage2 = { speed = 200,
				fuel = 4,
				homing = true,
				turn_speed =1,
				armed = true}
var stages = [stage1, stage2]
signal explode()
signal arm()
func _ready():
	boss = get_parent()
	curStage = stages.pop_front()
	if curStage!=null:
		speed = curStage["speed"]
		hasTarget = curStage["homing"]
		turnspeed = curStage["turn_speed"]
		$burnoutTimer.start(curStage["fuel"])
	else:
		print("missile had no first stage!")
		emit_signal("explode")
	pass
func updateTarget(_v):
#	print("missile target %s" % _v)
	v3 = _v
#	hasTarget = true
func _physics_process(delta):

	if accel * 2 <= max_speed:
		accel*=2
	if hasTarget and v3 != null:
		aimer.look_at(v3, Vector3.UP)
		var desQ = aimer.global_transform.basis.orthonormalized().get_rotation_quat()
		var curQ = boss.global_transform.basis.orthonormalized().get_rotation_quat()
		curQ = curQ.slerp(desQ, turnspeed*delta)
		boss.global_transform.basis = Basis(curQ.normalized())
	var vv = boss.global_transform.basis.xform(Vector3.FORWARD)
	if speed +accel*delta <= max_speed:
		speed +=  accel*delta
	vv *= speed
	var coll = boss.move_and_collide(vv * delta,false)
	if coll:
		emit_signal("explode")
		


func _on_burnoutTimer_timeout():
	curStage = stages.pop_front()
	if curStage != null:
		hasTarget = curStage["homing"]
		max_speed = curStage["speed"]
		turnspeed = curStage["turn_speed"]
		$burnoutTimer.start(curStage["fuel"])
		if curStage["armed"] == true:
			print("signal to arm")
			emit_signal("arm", true)
	else:
		emit_signal("explode")
	pass # Replace with function body.
