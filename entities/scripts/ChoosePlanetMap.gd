extends Node2D

var solarSystemScene = preload("res://entities/scenes/solarSystem.tscn")
const SAVE_PATH = "res://testing/saves/galaxySave.txt"

@onready var dialog = $CanvasLayer/PanelContainer
@onready var music = $Music

var planetAmount = 0

# Generates a full galaxy, saves it to disk, then cleans up the temporary nodes.
# Called when no save file exists (i.e. New Game).
func generateAndSave() -> void:
	# Ensure the saves directory exists
	var dir = DirAccess.open("res://testing/")
	if dir and not dir.dir_exists("saves"):
		dir.make_dir("saves")

	SaveLoadUtil.generateUniverse()

	# Wait a moment so all nodes fully initialize before saving
	await get_tree().create_timer(1.0).timeout

	var saveData = await SaveLoadUtil.toDict()

	var saveFile = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if saveFile:
		saveFile.store_string(JSON.stringify(saveData, "\t"))
		saveFile.close()
	else:
		push_error("New game: failed to write save file!")

	# Clean up — loadSave() will add the one visible system
	for child in get_children():
		if child is SolarSystem:
			child.queue_free()


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
		return

	# find a habitable system
	var livableSystem : Dictionary = {}
	for systemData in saveDict["systems"]:
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

	if livableSystem.is_empty():
		push_error("No habitable system found in save file!")
		return

	livableSystem["position"] = var_to_str(Vector2.ZERO)

	planetAmount = len(livableSystem["planetList"])

	var solarSys = solarSystemScene.instantiate()
	add_child(solarSys)
	solarSys.fromDict(livableSystem)


## Writes the settled planet's updated population back into the full save file.
func saveSettledPlanet(planet: Planet, orbital: Orbital) -> void:
	var saveString = FileAccess.get_file_as_string(SAVE_PATH)
	if saveString.is_empty():
		return
	var saveData = JSON.parse_string(saveString)
	if not saveData:
		return
	
	# save planet
	for systemDict in saveData["systems"]:
		if str_to_var(systemDict["starName"]) == planet.planetStarName:
			for pDict in systemDict["planetList"]:
				if str_to_var(pDict["planetName"]) == planet.planetName:
					pDict["currentPop"] = var_to_str(planet.currentPop)
					break
			break
	# save orbital
	saveData["orbitals"].append(orbital.toDict())

	var saveFile = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if saveFile:
		saveFile.store_string(JSON.stringify(saveData, "\t"))
		saveFile.close()
	else:
		push_error("Could not write settled planet back to save file!")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# If there's no save (New Game), generate the galaxy first
	if not FileAccess.file_exists(SAVE_PATH):
		await generateAndSave()

	# introductions
	await dialog.dialog(dialog.boi, "Hi, I'm Boi! (space to advance dialog)")
	await dialog.dialog(dialog.clunk, "And I'm Clunk!")
	await dialog.dialog(dialog.boi, "We're the robots that will help you play this game!")
	await dialog.dialog(dialog.clunk, "First, you need a planet to start on. Let's choose one!")
	music.change_song_with_fade("Planet Choosing")
	loadSave(SAVE_PATH)
	get_viewport().get_camera_2d().connect("planetClicked", discussPlanet)
	await dialog.dialog(dialog.boi, "Alright, let's choose a planet!")
	await dialog.dialog(dialog.clunk, "Click on a planet to see what it's like! Make sure to check out every planet!")
	


func kelvinToFahrenheit(kelvin : float) -> float:
	return (kelvin - 273.0) * (9.0 / 5.0) + 32.0


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
		var newOrbital = planet.addOrbital(Orbital.skyCity)
		saveSettledPlanet(planet, newOrbital)
		await dialog.dialog(dialog.clunk, "Welcome to {0}! Your 1,000 explorers are ready to settle.".format([planet.planetName]))
		await dialog.dialog(dialog.boi, "You chose well. This planet sits in the habitable zone — between 273K and 373K.")
		await dialog.dialog(dialog.clunk, "That's the temperature range where liquid water exists. And where there's water, there can be life!")
		await dialog.dialog(dialog.boi, "273K is the freezing point of water. 373K is the boiling point. Your planet is right in the middle — {0}K!".format([planet.planetTemperature]))
		await dialog.dialog(dialog.clunk, "But your system is just one tiny part of something much, much bigger...")
		await dialog.dialog(dialog.boi, "It's time to see the galaxy. Your journey is just beginning!")
		await music.fadeOut()
		get_tree().change_scene_to_file("res://entities/scenes/GAME.tscn")
