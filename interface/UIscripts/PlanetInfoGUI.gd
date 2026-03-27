class_name PlanetInfoGUI extends Control

@onready var NameLabel : RichTextLabel = $PanelContainer/Name
@onready var DescriptionLabel : RichTextLabel = $PanelContainer/Description

func set_name_label(name : String):
	NameLabel.text = name

func set_description_label(desc : String):
	DescriptionLabel.text = desc

func fill_planet_data(size : float, temp: float, number: int, starName: String):
	print("filling data")
	
