class_name Planet
extends Node2D

var MIN_SPIN_SPEED: float = 0.3
var MAX_SPIN_SPEED: float = 1.0

var text1 = load("res://assets/planets/Large red Gas + rings.png")
var text2 = load("res://assets/planets/Large red Gas.png")
var text3 = load("res://assets/planets/Pink gass 25 by 25.png")
var text4 = load("res://assets/planets/planet1.png")
var text5 = load("res://assets/planets/Rocky 15 pix.png")
var text6 = load("res://assets/planets/Tidaly Locked small.png")
var text7 = load("res://assets/planets/Yello + blue gass.png")

var TEXTURE_LIST = [text1,text2,text3,text4,text5,text6,text7]
@onready var Sprite: Sprite2D = $Sprite

var planet_size: int = 0
var planet_temperature: int = 0
var planet_order: int = 1

var star_name: String
var star_pos: Vector2
var orbit_size: float
var angle: float = 0.0
var orbitSpeed: float = 1.0
var spinSpeed: float = 0.0

var click: bool = false

func setup(s_pos: Vector2, starName: String, p_data = null) -> void:
	star_pos = s_pos
	star_name = starName
	orbit_size = position.distance_to(star_pos)
	orbitSpeed = (1.0 / sqrt(orbit_size / 100.0)) / 10.0
	orbitSpeed *= (1 if GlobalRNG.rng.randi_range(0, 1) == 0 else -1)
	spinSpeed = GlobalRNG.rng.randf_range(MIN_SPIN_SPEED, MAX_SPIN_SPEED)
	spinSpeed *= (1 if GlobalRNG.rng.randi_range(0, 1) == 0 else -1)

	if p_data != null:
		planet_size = p_data.size
		planet_temperature = p_data.temperature
		planet_order = p_data.order

func _process(delta: float) -> void:
	angle += orbitSpeed * delta
	position = star_pos + Vector2(cos(angle) * orbit_size, sin(angle) * orbit_size)
	rotation += spinSpeed * delta

func _ready():
	$Area2D.connect("input_event", _on_static_body_2d_input_event)
	$Area2D.connect("mouse_exited", _on_static_body_2d_mouse_exited)
	
	Sprite.texture = TEXTURE_LIST.pick_random()
	
func _on_static_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and not click:
		click = true
		var camera = get_viewport().get_camera_2d()
		if camera != null:
			camera.followed_planet = self

func _on_static_body_2d_mouse_exited() -> void:
	click = false
