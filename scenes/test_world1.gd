extends Spatial

func _ready():
	pass
func _input(event):
	if Input.is_action_just_pressed("ui_quit"):
		get_tree().quit()
