extends Camera2D

var dragging: bool = false
var dragStart: Vector2
var hasDragged: bool = false

var zoomMin: float = 0.08
var zoomMax: float = 8.0
var zoomSpeed: float = 0.1

var followedPlanet: Node2D = null

func _process(_delta: float) -> void:
	if followedPlanet != null and is_instance_valid(followedPlanet):
		position = followedPlanet.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				hasDragged = false
				dragStart = get_global_mouse_position()
			else:
				dragging = false

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var mouseBefore = get_global_mouse_position()
			zoom = clamp(zoom + Vector2(zoomSpeed, zoomSpeed),
						Vector2(zoomMin, zoomMin),
						Vector2(zoomMax, zoomMax))
			position += mouseBefore - get_global_mouse_position()

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var mouseBefore = get_global_mouse_position()
			zoom = clamp(zoom - Vector2(zoomSpeed, zoomSpeed),
						Vector2(zoomMin, zoomMin),
						Vector2(zoomMax, zoomMax))
			position += mouseBefore - get_global_mouse_position()

	if event is InputEventMouseMotion and dragging:
		hasDragged = true
		if followedPlanet != null:
			followedPlanet.hideGui()
		followedPlanet = null
		position -= event.relative / zoom.x
