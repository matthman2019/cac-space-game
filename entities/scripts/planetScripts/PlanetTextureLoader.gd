extends Node

var textureList = []

func loadPlanetTextures():
	var textureLocation = "res://assets/grayscalePlanets/"
	var fileAccess = DirAccess.open(textureLocation)
	for file in fileAccess.get_files():
		if file.ends_with(".import"):
			continue
		textureList.append(load(textureLocation.path_join(file)))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	loadPlanetTextures()
