extends ColorRect

func _setShaderBlur(value : float):
	material.set_shader_parameter("blurAmount", value)

func _setShaderDarkness(value : float):
	material.set_shader_parameter("darknessAmount", value)

func fadeOut():
	var blurTween = create_tween().set_trans(Tween.TRANS_LINEAR)
	blurTween.tween_method(_setShaderBlur, 0.0, 5.0, 2)
	var darkenTween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
	darkenTween.tween_method(_setShaderDarkness, 0.0, 1.0, 2.5)
	await darkenTween.finished

func fadeIn():
	var blurTween = create_tween().set_trans(Tween.TRANS_LINEAR)
	blurTween.tween_method(_setShaderBlur, 5.0, 0.0, 2)
	var darkenTween = create_tween().set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
	darkenTween.tween_method(_setShaderDarkness, 1.0, 0.0, 2.5)

func _ready():
	_setShaderBlur(0)
	_setShaderDarkness(0)
