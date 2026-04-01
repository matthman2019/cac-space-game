extends PanelContainer

var bracket_mode : bool = false
var pause_duration : float = 0.5 
var short_pause_duration : float = 0.2
var text_disp_id : int = 0

@onready var textbox = $HBoxContainer/MarginContainer2/RichTextLabel
@onready var imagebox = $HBoxContainer/MarginContainer/TextureRect

@onready var DEO = preload("res://assets/icons/Deo.jpg")
@onready var NATHAN = preload("res://assets/icons/Nathan.jpg")
@onready var BOI = preload("res://assets/icons/Boi3.png")

signal key_pressed
signal key_released

func _unhandled_key_input(event: InputEvent) -> void:
	if event.as_text() == "Space":
		if event.is_pressed():
			key_pressed.emit()
		else:
			key_released.emit()

func display_text_with_key(text : String, instantText : bool = false):
	await disp_text(text, instantText)
	await key_pressed
	await key_released

func disp_text(dispText : String, instantText : bool = false):
	text_disp_id += 1
	var local_text_disp_id = text_disp_id
	if instantText:
		textbox.text = dispText
		return
	
	textbox.text = ""
	for character in dispText:
		if character == "[":
			bracket_mode = true
		if character == "⏸":
			await get_tree().create_timer(pause_duration).timeout
			continue
		if not bracket_mode:
			await get_tree().process_frame
		if character == "]":
			bracket_mode = false
		
		# text_disp_id is to stop dialog if new dialog is shown (to prevent 2 dialog being mingled at once)
		if text_disp_id != local_text_disp_id:
			break
		textbox.text += character
		
		if character == ",":
			await get_tree().create_timer(short_pause_duration).timeout
	
	bracket_mode = false

func switch_image(image : Texture2D):
	imagebox.texture = image

func dialog(image : Texture2D, text : String):
	switch_image(image)
	await display_text_with_key(text, false)

func _ready():
	await dialog(BOI, "Deo it's time to lock in")
	await dialog(DEO, "No it's not. Nathan agrees")
	await dialog(NATHAN, "Even I'm locked in, Deo")
	await dialog(DEO, "Shoot")
