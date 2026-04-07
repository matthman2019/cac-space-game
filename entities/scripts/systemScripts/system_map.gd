class_name SystemMap
extends Node2D

var solarSystemScene = preload("res://entities/scenes/solarSystem.tscn")
var saveLocation: String = "res://testing/saves/galaxySave.txt"

class StarData:
	var name: String = "Star"
	var color: Color = Color.WHITE
	var size: float = 1.0
	func _init(starName: String, starColor: Color, starSize: float):
		name = starName
		color = starColor
		size = starSize

class PlanetData:
	var name: String = 'Unknown'
	var size: int = 0
	var order: int = 1
	var resources: Array = []
	var starName: String = 'Sol'
	var population: int = 0
	var researchPerSec: int = 0
	var totalResearch: int = 0
	var darkColor: Vector3 = Vector3.ZERO
	var lightColor: Vector3 = Vector3.ONE
	var orbitSize: float = 10.0
	var orbitSpeed = (1.0 / sqrt(orbitSize / 100.0)) / 10.0
	var spinSpeed: float = 1
	var textureID: int = 0
	func _init(planetName: String, planetSize: int, systemOrder: int, planetResources: Array, planetStarName: String,
	planetCurrentPop: int, planetResearchSec: int, planetTotalResearch: int, darkColorVec : Vector3, lightColorVec : Vector3,
	planetTextureID : int):
		name = planetName
		size = planetSize
		# temperature = planetTemp
		order = systemOrder
		resources = planetResources
		starName = planetStarName
		population = planetCurrentPop
		researchPerSec = planetResearchSec
		totalResearch = planetTotalResearch
		darkColor = darkColorVec
		lightColor = lightColorVec
		textureID = planetTextureID

class System:
	var location: Vector2 = Vector2(0, 0)
	var planets: Array = []
	var stars: Array = []
	func _init(pos: Vector2, planetList: Array, starList: Array):
		location = pos
		planets = planetList
		stars = starList

var UNIVERSE_SEED: int = 67676
var GALAXY_RADIUS: int = 15000
var GALAXY_CENTER: Vector2 = Vector2(0, 0)
var MIN_SYSTEMS: int = 20
var MAX_SYSTEMS: int = 30
var MIN_PLANETS: int = 1
var MAX_PLANETS: int = 5
var MIN_PLANET_SIZE: int = 10
var MAX_PLANET_SIZE: int = 100

var systemList: Array = []

func _ready() -> void:
	# placeholder for when the user will actually input something
	var savePath = saveLocation
	if savePath == null or (not FileAccess.file_exists(savePath)):
		generateUniverse()
	else:
		loadSave(savePath)

func generateUniverse():
	GlobalRNG.rng.seed = UNIVERSE_SEED

	for i in range(GlobalRNG.rng.randi_range(MIN_SYSTEMS, MAX_SYSTEMS)):
		var pos = Vector2(GALAXY_RADIUS * 2, GALAXY_RADIUS * 2)
		while (pos - GALAXY_CENTER).length() > GALAXY_RADIUS:
			pos = Vector2(
				GlobalRNG.rng.randf_range(-GALAXY_RADIUS, GALAXY_RADIUS),
				GlobalRNG.rng.randf_range(-GALAXY_RADIUS, GALAXY_RADIUS)
			)

		var starArray = StarGeneration.makeStar()
		var systemStarName: String = starArray[0]

		var planetList: Array = []
		var planetTextureAmount = len(PlanetTextureLoader.textureList) - 1
		for j in range(MIN_PLANETS, GlobalRNG.rng.randi_range(MIN_PLANETS + 1, MAX_PLANETS + 1)):
			var darkColor: Vector3 = Vector3(GlobalRNG.rng.randf_range(0, 0.5), GlobalRNG.rng.randf_range(0, 0.5), GlobalRNG.rng.randf_range(0, 0.5))
			var lightColor: Vector3 = Vector3(1, 1, 1) - darkColor
			planetList.append(PlanetData.new(
				PlanetNameGenerator.generate(),
				GlobalRNG.rng.randi_range(MIN_PLANET_SIZE, MAX_PLANET_SIZE),
				# GlobalRNG.rng.randi_range(MIN_PLANET_TEMP, MAX_PLANET_TEMP),
				j,
				[],
				systemStarName,
				0,
				0,
				0,
				darkColor,
				lightColor,
				GlobalRNG.rng.randi_range(0, planetTextureAmount)
			))

		var system = System.new(pos, planetList, [StarData.new(starArray[0], starArray[1], starArray[2])])
		systemList.append(system)

		var solarSys = solarSystemScene.instantiate()
		solarSys.position = pos
		add_child(solarSys)
		solarSys.loadSystem(system)

	await get_tree().create_timer(1.0).timeout
	save()

func toDict():
	var returnList = []
	for child in get_children():
		if child is SolarSystem:
			returnList.append(child.toDict())
	return returnList

func save():
	var saveData = JSON.stringify(toDict(), "	")
	# change this to user:// when we export
	var saveFile = FileAccess.open(saveLocation, FileAccess.WRITE)
	if saveFile:
		saveFile.store_string(saveData)
		saveFile.close()
		print("Written save data successfully!")
	else:
		push_error("Hey we weren't able to open / write the save file!")

func loadSave(newSaveLoc: String):
	assert(newSaveLoc != null)
	saveLocation = newSaveLoc
	var saveString = FileAccess.get_file_as_string(saveLocation)
	if saveString.is_empty():
		push_error("Hey we weren't able to open / write the save file: " + saveLocation)
		return
	
	var saveDict = JSON.parse_string(saveString)
	if not saveDict:
		push_error("Failed to parse save file: " + saveLocation)
	
	for system in saveDict:
		var solarSys = solarSystemScene.instantiate()
		add_child(solarSys)
		solarSys.fromDict(system)

	_focusSettledSystem()

# Positions the camera on the player's settled planet when loading into the game.
func _focusSettledSystem() -> void:
	var camera = get_viewport().get_camera_2d()
	if not camera:
		return
	for child in get_children():
		if not child is SolarSystem:
			continue
		for grandchild in child.get_children():
			if grandchild is Planet and grandchild.currentPop > 0:
				# Snap the camera position and start following the settled planet
				camera.position = grandchild.global_position
				camera.followedPlanet = grandchild
				return

# autosave on close
func _notification(what: int) -> void:
	if what == NOTIFICATION_WM_CLOSE_REQUEST:
		print("Quitting...")
		await save()
		get_tree().quit()
