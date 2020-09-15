extends KinematicBody
var canDamage = false
var v = Vector3()
var vn = Vector3()
export var SPEED = 100
export var DAMAGE = 10
export var lifespan = 2
export var team = "team_red"

func _ready():
	set_as_toplevel(true)
	$deathTimer.start(lifespan)
	canDamage = true
#	look_at(v, Vector3.UP)
	pass

func setTeam(_team):
	team = _team
func heading(pv):
	v = pv
	vn = v
	pass
func _process(delta):
	
	vn.y -= 30*delta
	var coll = move_and_collide(vn*delta, false)
	
	
	if coll != null:
		var hl = coll.collider.get_node_or_null("healthComponent")
		var thing = coll.collider
		if hl != null:
			if thing.has_method("getTeam"):
				if thing.call("getTeam") != self.team:
					hl.takeDamage(DAMAGE, global_transform.origin)
			var hit = FXContainer.packedRedHit.instance()
			hit.amount = 3
			FXContainer.add_child(hit)
			hit.global_transform.origin = self.global_transform.origin
		else:
			var hit = FXContainer.packedRedHit.instance()
			hit.amount = 3
			FXContainer.add_child(hit)
			hit.global_transform.origin = self.global_transform.origin
		queue_free()
	
func _on_Timer_timeout():
	canDamage = true
	$CollisionShape.disabled = false
	pass # Replace with function body.


func _on_deathTimer_timeout():
	queue_free()
	pass # Replace with function body.
