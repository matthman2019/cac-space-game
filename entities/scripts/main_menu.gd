extends Control

@onready var transitionNode = $Effect/Transitions
@onready var newGameButton = $VBoxContainer/NewGame
@onready var loadGameButton = $VBoxContainer/LoadGame
@onready var music = $Music

func newGame():
	get_tree().change_scene_to_file("res://entities/scenes/choosePlanetScene.tscn")

func loadGame():
	get_tree().change_scene_to_file("res://entities/scenes/GAME.tscn")

func fade():
	music.fadeOut()
	await transitionNode.fadeOut()


func _on_new_game_pressed() -> void:
	await fade()
	newGame()

func _on_load_game_pressed() -> void:
	await fade()
	loadGame()
