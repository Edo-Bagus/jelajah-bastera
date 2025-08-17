extends TextureButton

@export var is_baku: bool = false
@export var word: String = ""

@onready var label_front: Label = $Label

func _ready():
	label_front.text = word
	connect("pressed", Callable(self, "_on_pressed"))

# Fungsi untuk mengatur teks & status baku
func set_data(text: String, baku_status: bool):
	word = text
	is_baku = baku_status
	if label_front:
		label_front.text = text

func _on_pressed():
	emit_signal("batu_dipilih", is_baku)
