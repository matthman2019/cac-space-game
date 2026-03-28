class_name Planet
extends Node2D

var MIN_SPIN_SPEED: float = 0.3
var MAX_SPIN_SPEED: float = 1.0

var TEXTURE_LIST = []
@onready var Sprite: Sprite2D = $ShadedPlanet

# --- PLANET DATA ---
var planet_name: String = "Unknown"
var planet_size: int = 0
var planet_temperature: int = 0
var planet_order: int = 1
var planet_star_name: String = ""
var currentPop: int = 0
var researchPerSec: int = 0
var totalResearch: int = 0
var resources: Array = []

# --- ORBIT ---
var star_pos: Vector2
var orbit_size: float
var angle: float = 0.0
var orbitSpeed: float = 1.0
var spinSpeed: float = 0.0

var click: bool = false

func setup(s_pos: Vector2, p_data = null) -> void:
	star_pos = s_pos

	orbit_size = position.distance_to(star_pos)
	orbitSpeed = (1.0 / sqrt(orbit_size / 100.0)) / 10.0
	orbitSpeed *= (1 if GlobalRNG.rng.randi_range(0, 1) == 0 else -1)
	spinSpeed = GlobalRNG.rng.randf_range(MIN_SPIN_SPEED, MAX_SPIN_SPEED)
	spinSpeed *= (1 if GlobalRNG.rng.randi_range(0, 1) == 0 else -1)

	if p_data != null:
		planet_name = p_data.name
		planet_size = p_data.size
		planet_temperature = p_data.temperature
		planet_order = p_data.order
		planet_star_name = p_data.starName
		currentPop = p_data.population
		researchPerSec = p_data.researchPerSec
		totalResearch = p_data.totalResearch
		resources = p_data.resources

func _process(delta: float) -> void:
	angle += orbitSpeed * delta
	position = star_pos + Vector2(cos(angle) * orbit_size, sin(angle) * orbit_size)
	rotation += spinSpeed * delta

func _ready():
	$Area2D.connect("input_event", _on_static_body_2d_input_event)
	$Area2D.connect("mouse_exited", _on_static_body_2d_mouse_exited)
	load_planet_textures()
	Sprite.texture = TEXTURE_LIST.pick_random()

func _on_static_body_2d_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and not click and event.button_index == MOUSE_BUTTON_LEFT:
		click = true
		var camera = get_viewport().get_camera_2d()
		if camera != null:
			camera.followed_planet = self
		var gui = get_tree().get_first_node_in_group("planet_info_gui")
		if gui != null:
			gui.fill_planet_data(self)

func _on_static_body_2d_mouse_exited() -> void:
	click = false

func load_planet_textures():
	var textureLocation = "res://assets/grayscalePlanets/"
	var fileAccess = DirAccess.open(textureLocation)
	for file in fileAccess.get_files():
		if file.ends_with(".import"):
			continue
		TEXTURE_LIST.append(load(textureLocation.path_join(file)))
