class_name SolarSystem extends Node2D

var planetScene = preload("res://entities/scenes/planet.tscn")

@onready var starSprite = $Star/Sprite2D

var BASE_ORBIT_DISTANCE: float = 100.0
var MIN_ORBIT_SPACING: float = 160.0
var MAX_ORBIT_SPACING: float = 250.0
var MIN_STAR_ROTATION: float = 0.05
var MAX_STAR_ROTATION: float = 0.2
var STAR_BASE_SCALE: float = 1.0
var STAR_SIZE_SCALE: float = 0.08
var MIN_BASE_TEMP: int = 800
var MAX_BASE_TEMP: int = 1000

@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var rotationSpeed: float
@export_custom(PROPERTY_HINT_SAVE_FILE, "save") var starName: String = ""

func _process(delta: float) -> void:
	starSprite.rotation += rotationSpeed * delta

func loadSystem(system) -> void:
	for child in get_children():
		if child is Planet:
			child.queue_free()

	rotationSpeed = GlobalRNG.rng.randf_range(MIN_STAR_ROTATION, MAX_STAR_ROTATION)
	if GlobalRNG.rng.randi_range(0, 1) == 0:
		rotationSpeed *= -1.0

	# I see no reason to supress an error here
	if system == null:
		push_error("No system data was given!")
		return

	starName = system.stars[0].name
	print("generated star " + starName)
	starSprite.modulate = system.stars[0].color
	var s = STAR_BASE_SCALE + system.stars[0].size * STAR_SIZE_SCALE
	starSprite.scale = Vector2(s, s)

	for planetData in system.planets:
		var orbitDist = GlobalRNG.rng.randf_range(MIN_ORBIT_SPACING, MAX_ORBIT_SPACING)
		var orbit = BASE_ORBIT_DISTANCE + (planetData.order - 1) * orbitDist
		var temperature = GlobalRNG.rng.randf_range(MIN_BASE_TEMP, MAX_BASE_TEMP) / sqrt(orbit / 50)
		addPlanet(orbit, temperature, starName, planetData)

func addPlanet(orbit: float, temperature : float, _starName: String, planetData) -> void:
	var planet : Planet = planetScene.instantiate()
	planet.position = Vector2(orbit, 0)
	planet.planetTemperature = int(temperature)
	add_child(planet)
	planet.add_to_group("planets")
	planet.setup($Star.position, planetData)

func addPlanetFromDict(dict : Dictionary):
	var planet : Planet = planetScene.instantiate()
	planet.fromDict(dict)
	add_child(planet)
	planet.add_to_group("planets")
	
func toDict():
	var returnDict = {}
	for property in get_property_list():
		if property["hint_string"] == "save" or property["name"] == "position":
			@warning_ignore("shadowed_variable_base_class")
			var name = property["name"]
			returnDict[name] = var_to_str(self.get(name))
	var planetList = []
	for child in get_children():
		if child is Planet:
			planetList.append(child.toDict())
	returnDict["planetList"] = planetList
	return returnDict

func fromDict(data : Dictionary):
	for key in data.keys():
		if key == "planetList": continue
		set(key, str_to_var(data[key]))
	position = str_to_var(data["position"])
	
	for planetDict in data["planetList"]:
		addPlanetFromDict(planetDict)
