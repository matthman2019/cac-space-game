extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var shaderMaterial : ShaderMaterial = material
	var darkColor : Vector3 = Vector3(randf_range(0, 0.5), randf_range(0, 0.5), randf_range(0, 0.5))
	var lightColor : Vector3 = Vector3(randf_range(.5, 1), randf_range(.5, 1), randf_range(.5, 1))
	if shaderMaterial:
		shaderMaterial.set_shader_parameter("darkColor", darkColor)
		shaderMaterial.set_shader_parameter("lightColor", lightColor)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
