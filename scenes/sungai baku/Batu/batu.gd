extends TextureButton

@export var is_baku: bool = false
@export var word: String = ""

@onready var label_front: Label = $Label

func _ready():
	label_front.text = word
	connect("pressed", Callable(self, "_on_pressed"))
	_adjust_font_size()

# Fungsi untuk mengatur teks & status baku
func set_data(text: String, baku_status: bool):
	word = text
	is_baku = baku_status
	if label_front:
		label_front.text = text
		_adjust_font_size()

func _on_pressed():
	emit_signal("batu_dipilih", is_baku)

# Fungsi untuk set ukuran font dari parent button
func _adjust_font_size():
	if label_front:
		var base_size = 50
		var min_size = 8
		var size = base_size - (word.length() * 1.75)
		size = clamp(size, min_size, base_size)

		if label_front.label_settings:
			# clone biar nggak shared ke semua
			label_front.label_settings = label_front.label_settings.duplicate()
			label_front.label_settings.font_size = size
		else:
			label_front.add_theme_font_size_override("font_size", size)
