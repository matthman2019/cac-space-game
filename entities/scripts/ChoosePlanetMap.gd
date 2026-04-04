extends Node2D

var solarSystemScene = preload("res://entities/scenes/solarSystem.tscn")
@onready var dialog = $CanvasLayer/PanelContainer

var planetAmount = 0

# I am going to copy a lot of code
func loadSave(newSaveLoc: String):
	assert(newSaveLoc != null)
	var saveLocation = newSaveLoc
	var saveString = FileAccess.get_file_as_string(saveLocation)
	if saveString.is_empty():
		push_error("Hey we weren't able to open / write the save file: " + saveLocation)
		return
	
	var saveDict = JSON.parse_string(saveString)
	if not saveDict:
		push_error("Failed to parse save file: " + saveLocation)
	
	# find a habitable system
	var livableSystem : Dictionary = {}
	for systemData in saveDict:
		var cold = false
		var hot = false
		var right = false
		for planetDict in systemData["planetList"]:
			var temp = str_to_var(planetDict["planetTemperature"])
			if temp > 373: hot = true
			elif temp < 273: cold = true
			else: right = true
			if hot and cold and right:
				livableSystem = systemData
				break
	livableSystem["position"] = var_to_str(Vector2.ZERO)
	
	planetAmount = len(livableSystem["planetList"])
	
	var solarSys = solarSystemScene.instantiate()
	add_child(solarSys)
	solarSys.fromDict(livableSystem)
	
	
	
	


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadSave("res://testing/saves/galaxySave.txt")
	get_viewport().get_camera_2d().connect("planetClicked", discussPlanet)
	await dialog.dialog(dialog.boi, "Alright, let's choose a planet! (space to advance dialog)")
	await dialog.dialog(dialog.clunk, "Click on a planet to see what it's like! Make sure to check out every planet!")
	

func kelvinToFahrenheit(kelvin : float):
	return (kelvin - 273) * (9/5) + 32


var checkedNames : Array[String] = []
var canSettle : bool = false

func discussPlanet(planet : Planet):
	if planet.planetName not in checkedNames:
		checkedNames.append(planet.planetName)
	var temp = planet.planetTemperature
	var habitable = false
	if temp < 273:
		await dialog.dialog(dialog.boi, "Brr, that planet is cold!")
		await dialog.dialog(dialog.clunk, "{0} Kelvin is equivalent to {1} degrees fahrenheit! I wouldn't want to live there!".format([temp, kelvinToFahrenheit(temp)]))
	elif temp > 373:
		await dialog.dialog(dialog.boi, "That planet is too hot!")
		await dialog.dialog(dialog.clunk, "{0} Kelvin is equivalent to {1} degrees fahrenheit! I wouldn't want to live there!".format([temp, kelvinToFahrenheit(temp)]))
	else:
		habitable = true
		await dialog.dialog(dialog.boi, "That planet looks like a nice place to live!")
		await dialog.dialog(dialog.clunk, "{0} Kelvin is equivalent to {1} degrees fahrenheit! I could live there!".format([temp, kelvinToFahrenheit(temp)]))
	
	if len(checkedNames) == planetAmount and not canSettle:
		canSettle = true
		await dialog.dialog(dialog.boi, "Looks like you have checked out every planet! You can now choose a planet to settle on.")
	
	if not canSettle:
		return
	var settleChoice = await dialog.choice(dialog.boi, "Would you like to settle here?", ["Yes", "No"])
	if settleChoice == "No":
		await dialog.dialog(dialog.boi, "Ok then!")
	elif not habitable:
		await dialog.dialog(dialog.clunk, "Unfortunately, I'm going to have to override you on that one! Your civilization would not survive!")
	else:
		await dialog.dialog(dialog.boi, "Ok then! Let's settle here.")
		planet.currentPop += 1000


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
