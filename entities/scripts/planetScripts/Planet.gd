class_name Planet
extends Node2D

var MIN_SPIN_SPEED: float = 0.3
var MAX_SPIN_SPEED: float = 1.0

@onready var sprite: Sprite2D = $ShadedPlanet
@onready var gui = get_tree().get_first_node_in_group("planet_info_gui")
var orbitalScene = preload("res://entities/scenes/orbital.tscn")
var rocketScene = preload("res://entities/scenes/rocket.tscn")

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
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var textureID : int = 0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var uid: int = 0
# orbitals are not saved in planets
var orbitalList : Array[Orbital] = []

# --- ORBIT ---
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var starPos: Vector2
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var orbitSize: float
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var angle: float = 0.0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var orbitSpeed: float = 1.0
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var spinSpeed: float = 0.0

var click: bool = false
var _popAccumulator: float = 0.0
const GROWTH_RATE: float = 0.001  # 0.1% per second

# --- CIV ICON ---
var civIcon: Sprite2D = null
const ICON_SCREEN_SIZE: float = 28.0   # how wide the icon appears on screen in pixels
const ICON_SHOW_ZOOM: float = 0.8      # only visible below this camera zoom level

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
		planetOrder = pData.order
		planetStarName = pData.starName
		currentPop = pData.population
		researchPerSec = pData.researchPerSec
		totalResearch = pData.totalResearch
		resources = pData.resources
		darkColor = pData.darkColor
		lightColor = pData.lightColor
		sprite.setColors(darkColor, lightColor) # this must be run on setup()
		textureID = pData.textureID
		uid = pData.uid
	
	UidTracker.registerPlanet(self)

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

	# Keep the civ icon a constant screen size, floating above the planet
	if civIcon:
		var camera = get_viewport().get_camera_2d()
		if camera:
			var z = camera.zoom.x
			civIcon.visible = currentPop > 0 and z < ICON_SHOW_ZOOM
			if civIcon.visible:
				var tex := civIcon.texture
				# Scale so the icon is always ICON_SCREEN_SIZE pixels wide on screen
				civIcon.scale = Vector2(
					ICON_SCREEN_SIZE / (tex.get_width()  * z),
					ICON_SCREEN_SIZE / (tex.get_height() * z)
				)
				# Centered on the planet — fine to overlap when zoomed out
				civIcon.position = Vector2.ZERO
				# Cancel out the planet's spin so the icon always faces up
				civIcon.rotation = -rotation

func _ready():
	$Area2D.connect("input_event", _onStaticBody2dInputEvent)
	$Area2D.connect("mouse_exited", _onStaticBody2dMouseExited)
	sprite.texture = PlanetTextureLoader.textureList[textureID]
	$ShadedPlanet.setColors(darkColor, lightColor)

	# Build the civ icon sprite (hidden until this planet is settled and zoomed out)
	civIcon = Sprite2D.new()
	civIcon.texture = preload("res://assets/icons/civIcon.png")
	civIcon.visible = false
	civIcon.z_index = 10  # always draw on top of planets / stars
	add_child(civIcon)

func _onStaticBody2dInputEvent(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and not click and event.button_index == MOUSE_BUTTON_LEFT:
		click = true
		var camera = get_viewport().get_camera_2d()
		if camera:
			camera.followedPlanet = self
			camera.emit_signal("planetClicked", self)
		
		if gui:
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

func toDict():
	var returnDict = {}
	for property in get_property_list():
		if property["hint_string"] == "save" or property["name"] == "position":
			@warning_ignore("shadowed_variable_base_class")
			var name = property["name"]
			returnDict[name] = var_to_str(self.get(name))
	return returnDict

func fromDict(dict : Dictionary):
	for key in dict.keys():
		if key == "orbitalList": 
			continue
		set(key, str_to_var(dict[key]))
		if key == "uid": 
			UidTracker.registerPlanet(self)

# for ease
func addOrbital(texture : Texture2D) -> Orbital:
	var newOrbital : Orbital = orbitalScene.instantiate()
	newOrbital.planetParent = self
	newOrbital.planetParentUid = self.uid
	newOrbital.setTexture(texture)
	add_child(newOrbital)
	orbitalList.append(newOrbital)
	return newOrbital
