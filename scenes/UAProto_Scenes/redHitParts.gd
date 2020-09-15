extends Particles

func _ready():
	emitting = true
	$flashParts.emitting = true
	$groundBurnParts.emitting = true
	$Timer.start(2)
	pass


func _on_Timer_timeout():
	queue_free()
	pass # Replace with function body.
