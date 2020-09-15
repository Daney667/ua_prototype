extends Node
var mTeam
export var damage = 1
var victim
var collisionInfo 
func initDamage(pNode, pDamage, pTeam = null, pCollisionInfo = Vector3()):
	victim = pNode
	damage = pDamage
	collisionInfo = pCollisionInfo
	mTeam = pTeam
func _ready():
	doDamage()
	pass
func checkFriendly(pTeam):
	return pTeam == mTeam
func doDamage():
	if mTeam != null and victim != null:
		var victimTeam
		if victim.has_method("getTeam"):
			victimTeam = victim.getTeam()
		elif victim.get_parent_spatial().has_method("getTeam"):
			victimTeam = victim.get_parent_spatial().getTeam()
		if victimTeam != null:
			if !checkFriendly(victimTeam):
				if victim.find_node("healthComponent") != null:
					victim.get_node("healthComponent").takeDamage(damage, collisionInfo)
					print("%s takes damage" % str(victim.name))
			
				else:
					var owner = victim.get_parent_spatial()
					if owner != null:
						var comp = owner.get_node("healthComponent")
						if comp:
							comp.takeDamage(damage, collisionInfo)
							print("%s takes damage"% str(comp.name)) 
		else:
			print("NO VICTIM TEAM!!")
	else:
		print("No team assigned to bullet! or no victim")
#		if victim.find_node("healthComponent") != null:
#			victim.get_node("healthComponent").takeDamage(damage, collisionInfo)
#
#		else:
#			var owner = victim.get_parent_spatial()
#			if owner != null:
#				var comp = owner.get_node("healthComponent")
#				if comp:
#					comp.takeDamage(damage, collisionInfo)
	queue_free()
	pass
