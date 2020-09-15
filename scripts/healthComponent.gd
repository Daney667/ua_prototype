extends Node

export var hlth = 100
var maxHlth = hlth
var damage
var reprate = 0
export var canSelfRepair = false
export var mRepRate = 5
var myRepairer = null
onready var myOwner = get_parent()
var mEnergySupply
signal doDie
signal repairsDone()
func startRepairs(pRepairer):
	myRepairer = pRepairer
	if !self.is_connected("repairsDone", pRepairer, "on_repairsDone"):
		self.connect("repairsDone", pRepairer, "on_repairsDone")
func _ready():
	add_to_group("healthComponents")
	maxHlth = hlth
	mEnergySupply = myOwner.get_node_or_null("energyComponent")
func initHlth(p_hlth):
	hlth = p_hlth
	maxHlth = hlth
func set_owner(pOwner):
	myOwner = pOwner
func takeDamage(p_damage, pCollisionInfo = null):
	damage = p_damage
	hlth -= damage
#	print("in takeDamage...")
	if myOwner.has_method("getBlood"):
		var packedBlood = myOwner.getBlood()
		var blood = packedBlood.instance()
		print("adding blood")
		myOwner.add_child(blood)
		if pCollisionInfo is KinematicCollision:
			print("damage at kinematic position")
#			blood.global_transform.origin = pCollisionInfo.position
			blood.look_at_from_position(pCollisionInfo.position, pCollisionInfo.normal, Vector3.UP)
			blood.emitting = true
		else:
			blood.global_transform.origin = pCollisionInfo
			print("damage at v3 position " + convert(pCollisionInfo, TYPE_STRING))
			blood.emitting = true
	if hlth <= 0:
		killOwner()
func killOwner():
	if myOwner.has_method("die"):
		if myRepairer != null:
			stopRepairs()
		myOwner.call("die")
#		if myOwner.is_in_group("enemies"):
#			Economy.adjustCredits(maxHlth)
		print("killed owner") 
		queue_free()
	else:
		print("%s can't die???!!!" % myOwner.name)
	pass
func _process(delta):
	if myRepairer != null :
		reprate = mRepRate
		if hlth < maxHlth:
			hlth += reprate*delta
#			myRepairer.adjustEnergy(-reprate*delta)
			if isFull():
				hlth = maxHlth
				stopRepairs()
		if reprate > 0:
			if myRepairer.repcmp != self:
				stopRepairs()
	if canSelfRepair and hlth < maxHlth :
		if mEnergySupply.hasEnoughEnergy(maxHlth-hlth):			
			doSelfRepair(delta)
		else: 
			mEnergySupply.isEnergyDraining = false
			stopRepairs()
		
func doSelfRepair(delta):
	mEnergySupply.isEnergyDraining = true
	mEnergySupply.drainEnergy(mRepRate*delta)
	hlth += mRepRate*delta
	if isFull():
		mEnergySupply.isEnergyDraining = false
func stopRepairs():
	reprate = 0
	emit_signal("repairsDone")
	if myRepairer != null:
		if is_connected("repairsDone", myRepairer, "on_repairsDone"):
			disconnect("repairsDone", myRepairer, "on_repairsDone")
		if myRepairer.repcmp == self:
			myRepairer.repcmp = null
	myRepairer = null
	pass
func isFull():
	return (hlth >= maxHlth)
