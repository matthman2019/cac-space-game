extends Control

const SAVE_PATH = "res://testing/saves/galaxySave.txt"

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
	# Delete any existing save so choosePlanetScene generates a fresh galaxy
	if FileAccess.file_exists(SAVE_PATH):
		var dir = DirAccess.open("res://testing/saves/")
		if dir:
			dir.remove("galaxySave.txt")
	await fade()
	newGame()

func _on_load_game_pressed() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		var d = AcceptDialog.new()
		d.title = "No Save Found"
		d.dialog_text = "No save file found!\nStart a New Game first."
		d.confirmed.connect(d.queue_free)
		d.close_requested.connect(d.queue_free)
		add_child(d)
		d.popup_centered()
		return
	await fade()
	loadGame()
