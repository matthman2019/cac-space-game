class_name SystemMap
extends Node2D

var solar_system_scene = preload("res://entities/scenes/solarSystem.tscn")

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
	var temperature: int = 0
	var order: int = 1
	var resources: Array = []
	var starName: String = 'Sol'
	var population: int = 0
	var researchPerSec: int = 0
	var totalResearch: int = 0
	var darkColor : Vector3 = Vector3.ZERO
	var lightColor : Vector3 = Vector3.ONE
	var orbit_size : float = 10.0
	var orbitSpeed = (1.0 / sqrt(orbit_size / 100.0)) / 10.0
	var spinSpeed : float = 1
	func _init(planetName: String, planetSize: int, planetTemp: int, systemOrder: int, planetResources: Array, planetStarName: String,
	planetCurrentPop: int, planetResearchSec: int, planetTotalResearch: int, darkColorVec : Vector3, lightColorVec : Vector3):
		name = planetName
		size = planetSize
		temperature = planetTemp
		order = systemOrder
		resources = planetResources
		starName = planetStarName
		population = planetCurrentPop
		researchPerSec = planetResearchSec
		totalResearch = planetTotalResearch
		darkColor = darkColorVec
		lightColor = lightColorVec

class System:
	var location: Vector2 = Vector2(0, 0)
	var planets: Array = []
	var stars: Array = []
	func _init(pos: Vector2, planetList: Array, starList: Array):
		location = pos
		planets = planetList
		stars = starList

var UNIVERSE_SEED: int = 67676
var GALAXY_RADIUS: int = 5000
var GALAXY_CENTER: Vector2 = Vector2(0, 0)
var MIN_SYSTEMS: int = 20
var MAX_SYSTEMS: int = 30
var MIN_PLANETS: int = 1
var MAX_PLANETS: int = 5
var MIN_PLANET_SIZE: int = 10
var MAX_PLANET_SIZE: int = 100
var MIN_PLANET_TEMP: int = 40
var MAX_PLANET_TEMP: int = 1000

var systemList: Array = []

func _ready() -> void:
	GlobalRNG.rng.seed = UNIVERSE_SEED
	
	for i in range(GlobalRNG.rng.randi_range(MIN_SYSTEMS, MAX_SYSTEMS)):
		var pos = Vector2(GALAXY_RADIUS * 2, GALAXY_RADIUS * 2)
		while (pos - GALAXY_CENTER).length() > GALAXY_RADIUS:
			pos = Vector2(
				GlobalRNG.rng.randf_range(-GALAXY_RADIUS, GALAXY_RADIUS),
				GlobalRNG.rng.randf_range(-GALAXY_RADIUS, GALAXY_RADIUS)
			)
		
		var starArray = StarGeneration.MakeStar()
		var systemStarName: String = starArray[0]

		var planetList: Array = []
		for j in range(MIN_PLANETS, GlobalRNG.rng.randi_range(MIN_PLANETS + 1, MAX_PLANETS + 1)):
			var darkColor : Vector3 = Vector3(GlobalRNG.rng.randf_range(0, 0.5), GlobalRNG.rng.randf_range(0, 0.5), GlobalRNG.rng.randf_range(0, 0.5))
			var lightColor : Vector3 = Vector3(1, 1, 1) - darkColor
			planetList.append(PlanetData.new(
				PlanetNameGenerator.generate(),
				GlobalRNG.rng.randi_range(MIN_PLANET_SIZE, MAX_PLANET_SIZE),
				GlobalRNG.rng.randi_range(MIN_PLANET_TEMP, MAX_PLANET_TEMP),
				j,
				[],
				systemStarName,
				0,
				0,
				0,
				darkColor,
				lightColor
			))
		
		var system = System.new(pos, planetList, [StarData.new(starArray[0], starArray[1], starArray[2])])
		systemList.append(system)
		
		var solarSys = solar_system_scene.instantiate()
		solarSys.position = pos
		add_child(solarSys)
		solarSys.load_system(system)
	
	await get_tree().create_timer(1.0).timeout
	save()

func to_dict():
	var returnList = []
	for child in get_children():
		if child is SolarSystem:
			returnList.append(child.to_dict())
	return returnList

func save():
	var saveData = JSON.stringify(to_dict(), "	")
	# change this to user:// when we export
	var saveFile = FileAccess.open("res://testing/saves/galaxySave.txt", FileAccess.WRITE)
	if saveFile:
		saveFile.store_string(saveData)
		saveFile.close()
		print("Written save data successfully!")
	else:
		push_error("Hey we weren't able to open / write the save file!")
	
