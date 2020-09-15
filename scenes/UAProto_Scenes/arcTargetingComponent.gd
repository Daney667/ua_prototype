extends Node
export var targetGroup = "bot"
export var max_range = 1000
export var arc_degrees = 75
var closestTarget
var targetPosV
var targetList
onready var boss = get_parent()
signal closestTargetPosition()
signal noTargetInRange()
var doTargeting = true
func _ready():
	pass
func _process(delta):
	if doTargeting:
		targetClosest()

func targetClosest():
	targetList = get_tree().get_nodes_in_group(targetGroup)
	if !targetList.empty():
		var myPos = boss.global_transform.origin
		var curClosestDist = max_range
		closestTarget = null
		var dist
		#filter for within arc..
		for n in targetList:
			var targetPos = n.global_transform.origin
			
			pass
		#filter targets for distance from boss
		for n in targetList:
			var targetPos = n.global_transform.origin
			dist = myPos.distance_to(targetPos)
			if dist < curClosestDist:
				curClosestDist = dist
				closestTarget = n
		if closestTarget != null:
			
			emit_signal("closestTargetPosition", closestTarget.global_transform.origin)
		else:
			emit_signal("noTargetInRange")
	else:
		emit_signal("noTargetInRange")
	pass
