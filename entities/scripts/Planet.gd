class_name Planet
extends Sprite2D

var sunDistance: float
var mass: float
var orbitVel: float
var firstColonizable: bool

var star_pos: Vector2
var orbit_size: float
var angle: float = 0.0
var orbitSpeed: float = 1.0

func setup(s_pos: Vector2) -> void:
	star_pos = s_pos
	orbit_size = position.distance_to(star_pos)
	orbitSpeed = 1.0 / sqrt(orbit_size / 100.0)
	var direction = [-1, 1].pick_random()
	orbitSpeed *= direction

func _process(delta: float) -> void:
	angle += orbitSpeed * delta
	position = star_pos + Vector2(cos(angle) * orbit_size, sin(angle) * orbit_size)
