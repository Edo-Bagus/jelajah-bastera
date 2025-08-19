extends Control

@export var character_texture: Texture2D : set = set_character_texture
@export var character_name: String = "" : set = set_character_name
@export_multiline var dialog_text: String = "" : set = set_dialog_text

# Tambahan: array dialog
@export var dialog_lines: Array[String] = []   # isi semua dialog di inspector
var current_index: int = 0

@onready var character_image: TextureRect = $Panel/CharacterImage
@onready var name_label: Label = $Panel/CharacterName
@onready var dialog_label: RichTextLabel = $Panel/DialogText
@onready var next_button: Button = $Panel/NextButton

func set_character_texture(value: Texture2D) -> void:
	character_texture = value
	if character_image:
		character_image.texture = value

func set_character_name(value: String) -> void:
	character_name = value
	if name_label:
		name_label.text = value

func set_dialog_text(value: String) -> void:
	dialog_text = value
	if dialog_label:
		dialog_label.text = value

func _ready():
	set_character_texture(character_texture)
	set_character_name(character_name)

	# kalau ada isi dialog_lines → pakai itu
	if dialog_lines.size() > 0:
		current_index = 0
		set_dialog_text(dialog_lines[current_index])
	else:
		set_dialog_text(dialog_text)

	next_button.pressed.connect(_on_next_pressed)

func _on_next_pressed() -> void:
	if dialog_lines.size() == 0:
		# kalau cuma satu dialog_text
		hide()
		return

	current_index += 1
	if current_index < dialog_lines.size():
		set_dialog_text(dialog_lines[current_index])
	else:
		hide()  # habis dialog → tutup popup
