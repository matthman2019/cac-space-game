extends Node2D

var planet_scene = preload("res://entities/scenes/planet.tscn")

@onready var star_sprite = $Star/Sprite2D

var BASE_ORBIT_DISTANCE: float = 100.0
var MIN_ORBIT_SPACING: float = 160.0
var MAX_ORBIT_SPACING: float = 250.0
var MIN_STAR_ROTATION: float = 0.05
var MAX_STAR_ROTATION: float = 0.2
var STAR_BASE_SCALE: float = 1.0
var STAR_SIZE_SCALE: float = 0.08

var rotation_speed: float
var star_name: String = ""

func _process(delta: float) -> void:
	star_sprite.rotation += rotation_speed * delta

func load_system(system) -> void:
	for child in get_children():
		if child is Planet:
			child.queue_free()

	rotation_speed = GlobalRNG.rng.randf_range(MIN_STAR_ROTATION, MAX_STAR_ROTATION)
	if GlobalRNG.rng.randi_range(0, 1) == 0:
		rotation_speed *= -1.0

	if system == null:
		for i in range(3):
			var orbitDist = GlobalRNG.rng.randf_range(MIN_ORBIT_SPACING,MAX_ORBIT_SPACING)
			add_planet(BASE_ORBIT_DISTANCE + i * orbitDist,"Fallback Star", null)
		return

	star_name = system.stars[0].name
	print("generated star "+star_name)
	star_sprite.modulate = system.stars[0].color
	var s = STAR_BASE_SCALE + system.stars[0].size * STAR_SIZE_SCALE
	star_sprite.scale = Vector2(s, s)

	for planet_data in system.planets:
		var orbitDist = GlobalRNG.rng.randf_range(MIN_ORBIT_SPACING,MAX_ORBIT_SPACING)
		var orbit = BASE_ORBIT_DISTANCE + (planet_data.order - 1) * orbitDist
		add_planet(orbit, star_name, planet_data)

func add_planet(orbit: float, star_name: String, planet_data) -> void:
	var planet : Planet = planet_scene.instantiate()
	planet.get_node("ShadedPlanet").shuffleColor()
	planet.position = Vector2(orbit, 0)
	add_child(planet)
	planet.setup($Star.position, star_name, planet_data)
