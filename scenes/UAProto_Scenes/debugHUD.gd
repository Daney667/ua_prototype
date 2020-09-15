extends Control

func _ready():
	pass
func _process(delta):
	if get_parent().has_method("getAltitude"):
		$AltitudeLabel.text = "Altitude: %s" %get_parent().call("getAltitude")
	if get_parent().has_method("getThrust"):
		$AccelLabel.text = "Thrust: %s" %get_parent().call("getThrust")
	if get_parent().has_method("getDistanceX"):
		$RangeLabel.text = "DistanceX: %s" %get_parent().call("getDistanceX")
	if get_parent().has_method("getSpeed"):
		$VelocityLabel.text = "L Vel: %s" %get_parent().call("getSpeed")
	if get_parent().isOccupied():
		visible = true
	else:
		visible = false
