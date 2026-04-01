class_name Planet
extends Node2D

var MIN_SPIN_SPEED: float = 0.3
var MAX_SPIN_SPEED: float = 1.0

var textureList = []
@onready var sprite: Sprite2D = $ShadedPlanet
@onready var gui = get_tree().get_first_node_in_group("planet_info_gui")

# --- PLANET DATA ---
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetName: String = "Unknown"
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetSize: int = 0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetTemperature: int = 0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetOrder: int = 1
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var planetStarName: String = ""
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var currentPop: int = 0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var researchPerSec: float = 0.0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var totalResearch: float = 0.0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var resources: Array = []
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var darkColor: Vector3 = Vector3.ZERO
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var lightColor: Vector3 = Vector3.ONE

# --- ORBIT ---
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var starPos: Vector2
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var orbitSize: float
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var angle: float = 0.0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var orbitSpeed: float = 1.0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var spinSpeed: float = 0.0

var click: bool = false
var _popAccumulator: float = 0.0
const GROWTH_RATE: float = 0.001  # 0.1% per second

func setup(sPos: Vector2, pData = null) -> void:
	starPos = sPos

	orbitSize = position.distance_to(starPos)
	orbitSpeed = (1.0 / sqrt(orbitSize / 100.0)) / 10.0
	orbitSpeed *= (1 if GlobalRNG.rng.randi_range(0, 1) == 0 else -1)
	spinSpeed = GlobalRNG.rng.randf_range(MIN_SPIN_SPEED, MAX_SPIN_SPEED)
	spinSpeed *= (1 if GlobalRNG.rng.randi_range(0, 1) == 0 else -1)

	if pData != null:
		planetName = pData.name
		planetSize = pData.size
		planetTemperature = pData.temperature
		planetOrder = pData.order
		planetStarName = pData.starName
		currentPop = pData.population
		researchPerSec = pData.researchPerSec
		totalResearch = pData.totalResearch
		resources = pData.resources
		darkColor = pData.darkColor
		lightColor = pData.lightColor
		sprite.setColors(darkColor, lightColor) # this must be run on setup()

func _process(delta: float) -> void:
	angle += orbitSpeed * delta
	position = starPos + Vector2(cos(angle) * orbitSize, sin(angle) * orbitSize)
	rotation += spinSpeed * delta

	if currentPop > 0:
		_popAccumulator += currentPop * GROWTH_RATE * delta
		if _popAccumulator >= 1.0:
			currentPop += int(_popAccumulator)
			_popAccumulator = fmod(_popAccumulator, 1.0)

	self.researchPerSec = self.currentPop / 1000.0
	self.totalResearch += researchPerSec * delta

func _ready():
	$Area2D.connect("input_event", _onStaticBody2dInputEvent)
	$Area2D.connect("mouse_exited", _onStaticBody2dMouseExited)
	loadPlanetTextures()
	sprite.texture = textureList.pick_random()

func _onStaticBody2dInputEvent(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	if event is InputEventMouseButton and not click and event.button_index == MOUSE_BUTTON_LEFT:
		click = true
		var camera = get_viewport().get_camera_2d()
		if camera != null:
			camera.followedPlanet = self
		if gui != null:
			gui.fillPlanetData(self)
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_MIDDLE:
		self.currentPop += 50
		#print("added population")
		gui.fillPlanetData(self)

func _onStaticBody2dMouseExited() -> void:
	click = false

func hideGui():
	if gui != null:
		gui.visible = false

func loadPlanetTextures():
	var textureLocation = "res://assets/grayscalePlanets/"
	var fileAccess = DirAccess.open(textureLocation)
	for file in fileAccess.get_files():
		if file.ends_with(".import"):
			continue
		textureList.append(load(textureLocation.path_join(file)))

func toDict():
	var returnDict = {}
	for property in get_property_list():
		if property["hint_string"] == "save":
			var name = property["name"]
			returnDict[name] = self.get(name)
	return returnDict
