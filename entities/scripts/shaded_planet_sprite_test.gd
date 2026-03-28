extends Sprite2D

func shuffleColor():
	var shaderMaterial : ShaderMaterial = material
	var darkColor : Vector3 = Vector3(GlobalRNG.rng.randf_range(0, 0.5), GlobalRNG.rng.randf_range(0, 0.5), GlobalRNG.rng.randf_range(0, 0.5))
	var lightColor : Vector3 = Vector3(1, 1, 1) - darkColor #  Vector3(GlobalRNG.rng.randf_range(.5, 1), GlobalRNG.rng.randf_range(.5, 1), GlobalRNG.rng.randf_range(.5, 1))
	if shaderMaterial:
		self.set_instance_shader_parameter("darkColor", darkColor)
		self.set_instance_shader_parameter("lightColor", lightColor)
	
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	shuffleColor()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
