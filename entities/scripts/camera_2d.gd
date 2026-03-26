extends Camera2D

var dragging: bool = false
var drag_start: Vector2

var zoom_min: float = 0.1
var zoom_max: float = 8.0
var zoom_speed: float = 0.1

var followed_planet: Node2D = null

func _process(_delta: float) -> void:
	if followed_planet != null and is_instance_valid(followed_planet):
		position = followed_planet.global_position

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				dragging = true
				drag_start = get_global_mouse_position()
				followed_planet = null
			else:
				dragging = false

		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			var mouse_before = get_global_mouse_position()
			zoom = clamp(zoom + Vector2(zoom_speed, zoom_speed),
						Vector2(zoom_min, zoom_min),
						Vector2(zoom_max, zoom_max))
			position += mouse_before - get_global_mouse_position()

		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			var mouse_before = get_global_mouse_position()
			zoom = clamp(zoom - Vector2(zoom_speed, zoom_speed),
						Vector2(zoom_min, zoom_min),
						Vector2(zoom_max, zoom_max))
			position += mouse_before - get_global_mouse_position()
		
	if event is InputEventMouseMotion and dragging:
		position -= event.relative / zoom.x
