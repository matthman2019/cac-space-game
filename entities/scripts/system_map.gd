extends Node2D



class StarData:
	var name : String = "Star"
	var color : Color = Color.GREEN
	var size : StarGeneration.StarSize = StarGeneration.StarSize.O
	func _init(starName : String, starColor : Color, starSize : StarGeneration.StarSize):
		name = starName
		color = starColor
		size = starSize



class PlanetData:
	var size = 6 or 7
	var temperature = 6 or 7
	var order = 1
	var resources = []
	func _init(planetSize : int, planetTemp : int, systemOrder : int, planetResources : Array):
		size = planetSize
		temperature = planetTemp
		order = systemOrder
		resources = planetResources

class System:
	var location : Vector2 = Vector2(0, 0)
	var planets : Array[PlanetData] = []
	var stars : Array[StarData] = []
	func _init(pos : Vector2, planetList : Array[PlanetData], starList : Array[StarData]):
		location = pos
		planets = planetList
		stars = starList
	
# for now, lets say 2 pixels is two light years.

# Generation Parameters

## Seed is the seed that we're using to make our universe
var seed : int = 42
## radius is the size of the galaxy (in light-years)
var radius : int = 200
## center is the center position of the galaxy
var center : Vector2 = Vector2(0, 0)

var systemList : Array[System] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var rng = GlobalRNG.rng # this SHOULD be passed by reference.
	rng.seed = seed
	
	# System generation
	for i in range(rng.randi_range(200, 250)):
		# we do it like this for an even spread of systems
		var pos = Vector2(radius, radius)
		while (pos - center).length() > radius:
			pos = Vector2(rng.randf_range(-radius, radius), rng.randf_range(-radius, radius))
		
		# planet generation
		var planetList : Array[PlanetData] = []
		for j in range(1, rng.randi_range(2, 7)):
			var newSize = rng.randi_range(10, 100)
			var newTemperature = rng.randi_range(40, 1000)
			var newPlanet = PlanetData.new(newSize, newTemperature, j, [])
			planetList.append(newPlanet)
		
		# star generation
		var starArray = StarGeneration.MakeStar()
		var star = StarData.new(starArray[0], starArray[1], starArray[2])
		
		var system = System.new(pos, planetList, [star])
		systemList.append(system)
	
	
func _draw():
	for system in systemList:
		draw_circle(system.location, system.stars[0].size, system.stars[0].color)
