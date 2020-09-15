extends PathFollow

func _ready():
	loop = true
	pass
func _physics_process(delta):
	offset += 30 * delta 
	
