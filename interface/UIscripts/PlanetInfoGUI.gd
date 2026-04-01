class_name PlanetInfoGUI extends Control

@onready var nameLabel: RichTextLabel = $PanelContainer/Name
@onready var descriptionLabel: RichTextLabel = $PanelContainer/Description

var currentPlanet: Planet = null

func _ready():
	add_to_group("planet_info_gui")
	visible = false

func _process(_delta: float) -> void:
	if currentPlanet != null and visible:
		fillPlanetData(currentPlanet)

func fillPlanetData(planet: Planet):
	currentPlanet = planet
	nameLabel.text = planet.planetName

	var resourceText: String
	if planet.resources.is_empty():
		resourceText = "[color=gray]None surveyed[/color]"
	else:
		resourceText = ", ".join(planet.resources)

	descriptionLabel.text = (
		"Orbiting [color=orange]%s[/color]\n" % planet.planetStarName +
		"Size: [color=teal]%d km[/color]\n" % planet.planetSize +
		"Temperature: [color=red]%d K[/color]\n" % planet.planetTemperature +
		"Resources: %s\n" % resourceText +
		"Population: [color=cyan]%d[/color]\n" % planet.currentPop +
		"Research/min: [color=cyan]%d[/color]\n" % (planet.researchPerSec * 60) +
		"Total Research: [color=cyan]%d[/color]" % planet.totalResearch
	)

	visible = true
