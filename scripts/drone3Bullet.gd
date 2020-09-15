extends KinematicBody
var heading
export var speed = 60
export var damage = 20

var sparks
const packedDamageComponent = preload("res://scenes/damageComponent.tscn")
func _ready():
	
	pass

func _physics_process(delta):
	if heading != null:
		var collision = move_and_collide(heading * delta)
		if collision:
			if sparks != null:
				var s = sparks.instance()
				FXContainer.add_child(s)
				s.global_transform.origin = global_transform.origin
				s.emitting =true
				
				var body = collision.get_collider()
				var damCompo = packedDamageComponent.instance()
				damCompo.initDamage(body, damage,"enemies", collision)
				body.add_child(damCompo)
			queue_free()
func setHeading(v):
	heading  = v * speed
func _on_lifeTimer_timeout():
	queue_free()
	pass # Replace with function body.
