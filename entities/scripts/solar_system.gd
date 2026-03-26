extends Node2D

var planet_scene = preload("res://entities/scenes/planet.tscn")

var starMass: float
var starLife: float

func _ready() -> void:
	add_planet(80.0)
	add_planet(160.0)
	add_planet(260.0)

func add_planet(orbit: float) -> void:
	var planet = planet_scene.instantiate()
	planet.position = Vector2(orbit, 0)
	add_child(planet)
	planet.setup($Star.position)
