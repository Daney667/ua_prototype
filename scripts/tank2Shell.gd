extends KinematicBody
export var speed = 40
export var damage = 25
const packedHit = preload("res://scenes/droneBullet1Hit.tscn")
var v = Vector3(0,0,0)

func _ready():
	pass # Replace with function body.
func heading(pV):
	v = pV
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if v != null:
#		look_at(v,Vector3.UP)
		
#		v.y -= (1/(pow(9.81,2)))*delta
		var collision = move_and_collide(v.normalized()*delta*speed)
		if (collision != null ):
			var body = collision.get_collider()
#			print(body.name)
			if body.find_node("healthComponent") != null:
				body.get_node("healthComponent").takeDamage(damage, Vector3(0,0,0))
				var mHit = packedHit.instance()
				var hitV = collision.position
				FXContainer.add_child(mHit)
				var nrm = collision.normal
				mHit.global_transform.origin = hitV
				mHit.look_at(nrm, Vector3(1,0,0))
			else:
				var owner = body.get_parent_spatial()
				if owner != null:
					if owner.get_node("healthComponent") != null:
						owner.get_node("healthComponent").takeDamage(damage, Vector3(0,0,0))
			var mHit = packedHit.instance()
			var hitV = collision.position
			FXContainer.add_child(mHit)
			mHit.global_transform.origin = hitV
			var nrm = collision.normal
			mHit.look_at(nrm, Vector3(1,0,0))
			stopEmitting()
		
	pass


func stopEmitting():
	$MotionTrail.motionDelta = 10000
	v = null
	$CollisionShape.disabled = true
	$MeshInstance.visible =false
	pass
func _on_lifeTimer_timeout():
	stopEmitting()
	pass # Replace with function body.


func _on_endEmitTimer_timeout():
	queue_free()
	pass # Replace with function body.
