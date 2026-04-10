extends Node

# find_children("*") just wouldn't work
# this was taken from
# https://www.reddit.com/r/godot/comments/40cm3w/looping_through_all_children_and_subchildren_of_a/
func getAllChildren(node : Node):
	var nodes : Array = []
	for N in node.get_children():
		if N.get_child_count() > 0:
			nodes.append(N)
			nodes.append_array(getAllChildren(N))
		else:
			nodes.append(N)
	return nodes

func toDict():
	var systemSaveList = []
	var orbitalSaveList = []
	var children = getAllChildren(get_tree().current_scene)
	for child in children:
		if child is SolarSystem:
			systemSaveList.append(child.toDict())
		if child is Orbital:
			orbitalSaveList.append(child.toDict())
	var returnDict = {
		"systems" : systemSaveList,
		"orbitals" : orbitalSaveList
	}
	return returnDict

# generation stuff

var UNIVERSE_SEED: int = 67676
var GALAXY_RADIUS: int = 15000
var GALAXY_CENTER: Vector2 = Vector2(0, 0)
var MIN_SYSTEMS: int = 20
var MAX_SYSTEMS: int = 30
var MIN_PLANETS: int = 1
var MAX_PLANETS: int = 5
var MIN_PLANET_SIZE: int = 10
var MAX_PLANET_SIZE: int = 100

var solarSystemScene = preload("res://entities/scenes/solarSystem.tscn")
var saveLocation: String = "res://testing/saves/galaxySave.txt"
var systemList: Array = []


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

func generateUniverse():
	var currentScene = get_tree().current_scene
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
		currentScene.add_child(solarSys)
		solarSys.loadSystem(system)
