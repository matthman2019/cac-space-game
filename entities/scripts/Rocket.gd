class_name Rocket extends Orbital


func _ready():
	super._ready()
	theta = 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super._process(delta)
	global_rotation = -theta + (PI/2)
