extends Node2D

var planet_scene = preload("res://entities/scenes/planet.tscn")

#@onready var sprite = $Sprite

var starMass: float
var starLife: float
var rotation_speed: float

func _ready() -> void:
	add_planet(80.0)
	add_planet(160.0)
	add_planet(260.0)
	rotation_speed = -100

func _process(delta: float) -> void:
	#sprite.rotation = rotation_speed*delta

func add_planet(orbit: float) -> void:
	var planet = planet_scene.instantiate()
	planet.position = Vector2(orbit, 0)
	add_child(planet)
	planet.setup($Star.position)
