extends Spatial
var m_owner = "neutral"
export var powerLevel = 1

func _ready():
	pass
func changeOwner(pOwner):
	m_owner = pOwner
