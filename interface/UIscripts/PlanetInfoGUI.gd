class_name PlanetInfoGUI extends Control

@onready var NameLabel: RichTextLabel = $PanelContainer/Name
@onready var DescriptionLabel: RichTextLabel = $PanelContainer/Description

func _ready():
	add_to_group("planet_info_gui")
	visible = false

func fill_planet_data(planet: Planet):
	NameLabel.text = planet.planet_name

	var resource_text: String
	if planet.resources.is_empty():
		resource_text = "[color=gray]None surveyed[/color]"
	else:
		resource_text = ", ".join(planet.resources)

	DescriptionLabel.text = (
		"Orbiting [color=orange]%s[/color]\n" % planet.planet_star_name +
		"Size: [color=teal]%d km[/color]\n" % planet.planet_size +
		"Temperature: [color=red]%d K[/color]\n" % planet.planet_temperature +
		"Resources: %s\n" % resource_text +
		"Population: [color=cyan]%d[/color]\n" % planet.currentPop +
		"Research/sec: [color=cyan]%d[/color]\n" % planet.researchPerSec +
		"Total Research: [color=cyan]%d[/color]" % planet.totalResearch
	)

	visible = true
