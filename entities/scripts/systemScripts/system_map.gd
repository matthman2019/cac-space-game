class_name SystemMap
extends Node2D

var solarSystemScene = preload("res://entities/scenes/solarSystem.tscn")
var saveLocation: String = "res://testing/saves/galaxySave.txt"
var systemList: Array = []

func _ready() -> void:
	# placeholder for when the user will actually input something
	var savePath = saveLocation
	if savePath == null or (not FileAccess.file_exists(savePath)):
		push_error("There is no save file to load!")
	else:
		loadSave(savePath)



func save():
	var saveData = JSON.stringify(SaveLoadUtil.toDict(), "	")
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
	
	var saveDict : Dictionary = JSON.parse_string(saveString)
	if not saveDict:
		push_error("Failed to parse save file: " + saveLocation)
	for system in saveDict["systems"]:
		var solarSys = solarSystemScene.instantiate()
		add_child(solarSys)
		solarSys.fromDict(system)
	for orbital in saveDict["orbitals"]:
		var orbitalUid = str_to_var(orbital["planetParentUid"])
		UidTracker.getPlanet(orbitalUid).addOrbital(Orbital.skyCity)

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
