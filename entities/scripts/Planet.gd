class_name Planet
extends Node2D

var sunDistance: float
var mass: float
var orbitVel: float
var firstColonizable: bool

var star_pos: Vector2
var orbit_size: float
var angle: float = 0.0
var orbitSpeed: float = 1.0
var spinSpeed: float = 0.0

var click: bool=false

func setup(s_pos: Vector2) -> void:
	star_pos = s_pos
	orbit_size = position.distance_to(star_pos)
	orbitSpeed = (1.0 / sqrt(orbit_size / 100.0))/10
	var direction = [-1, 1].pick_random()
	orbitSpeed *= direction
	spinSpeed = randf_range(0.3, 1.0) * ([-1, 1].pick_random())

func _process(delta: float) -> void:
	angle += orbitSpeed * delta
	position = star_pos + Vector2(cos(angle) * orbit_size, sin(angle) * orbit_size)
	rotation += spinSpeed * delta
	
func _on_static_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	#print("static 2d imput")
	if event is InputEventMouseButton and not click:
		click = true
		var camera = get_viewport().get_camera_2d()
		if camera != null:
			camera.followed_planet = self
			
func _ready():
	$Area2D.connect("input_event", _on_static_body_2d_input_event)
	$Area2D.connect("mouse_exited", _on_static_body_2d_mouse_exited)


func _on_static_body_2d_mouse_exited() -> void:
	#print("mouse exited")
	click = false
