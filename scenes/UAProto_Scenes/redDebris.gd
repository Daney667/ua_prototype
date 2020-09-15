extends RigidBody
var life = 10
func _ready():
	$deathTimer.start(life + randi()%life)
	pass


func _on_deathTimer_timeout():
	queue_free()
	pass # Replace with function body.
