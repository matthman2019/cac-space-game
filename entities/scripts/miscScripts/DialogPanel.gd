extends PanelContainer

var bracketMode : bool = false
var pauseDuration : float = 0.5
var shortPauseDuration : float = 0.2
var textDispId : int = 0

@onready var textbox = $HBoxContainer/MarginContainer2/RichTextLabel
@onready var imagebox = $HBoxContainer/MarginContainer/TextureRect

@onready var deo = preload("res://assets/icons/Deo.jpg")
@onready var nathan = preload("res://assets/icons/Nathan.jpg")
@onready var boi = preload("res://assets/icons/Boi3.png")

signal keyPressed
signal keyReleased

func _unhandled_key_input(event: InputEvent) -> void:
	if event.as_text() == "Space":
		if event.is_pressed():
			keyPressed.emit()
		else:
			keyReleased.emit()

func displayTextWithKey(text : String, instantText : bool = false):
	await dispText(text, instantText)
	await keyPressed
	await keyReleased

func dispText(dispText : String, instantText : bool = false):
	textDispId += 1
	var localTextDispId = textDispId
	if instantText:
		textbox.text = dispText
		return

	textbox.text = ""
	for character in dispText:
		if character == "[":
			bracketMode = true
		if character == "⏸":
			await get_tree().create_timer(pauseDuration).timeout
			continue
		if not bracketMode:
			await get_tree().process_frame
		if character == "]":
			bracketMode = false

		# textDispId is to stop dialog if new dialog is shown (to prevent 2 dialog being mingled at once)
		if textDispId != localTextDispId:
			break
		textbox.text += character

		if character == ",":
			await get_tree().create_timer(shortPauseDuration).timeout

	bracketMode = false

func switchImage(image : Texture2D):
	imagebox.texture = image

func dialog(image : Texture2D, text : String):
	switchImage(image)
	await displayTextWithKey(text, false)

func _ready():
	await dialog(boi, "Deo it's time to lock in")
	await dialog(deo, "No it's not. Nathan agrees")
	await dialog(nathan, "Even I'm locked in, Deo")
	await dialog(deo, "Shoot")
