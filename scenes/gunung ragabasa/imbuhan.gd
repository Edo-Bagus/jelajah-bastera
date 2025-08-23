extends Panel

@onready var label: Label = $Label
var _dragging := false
var _drop_succeeded := false # Variabel baru untuk melacak status drop
var doodle_font = load("res://assets/Fonts/your-doodle-font/Your Doodle Font.ttf")

func set_text(txt: String) -> void:
	label.text = txt

func _get_drag_data(at_position):
	_drop_succeeded = false # Reset status drop saat drag dimulai
	
	# --- Kode preview drag ---
	var preview_label := Label.new()
	preview_label.text = label.text
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_size_override("font_size", 30)
	preview_label.add_theme_color_override("font_color", Color.BLACK)
	preview_label.add_theme_font_override("font", doodle_font)
	preview_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_label.offset_left = 0
	preview_label.offset_top = 0
	preview_label.offset_right = 0
	preview_label.offset_bottom = 0

	var preview := Panel.new()
	preview.custom_minimum_size = size
	preview.modulate = modulate

	var style_override = get("res://scenes/gunung ragabasa/panel.tres")
	if style_override:
		preview.add_theme_stylebox_override("panel", style_override.duplicate(true))
	else:
		var base_style := get_theme_stylebox("panel")
		if base_style:
			preview.add_theme_stylebox_override("panel", base_style.duplicate(true))

	preview.add_child(preview_label)
	set_drag_preview(preview)

	visible = false
	_dragging = true

	return {
		"type": "imbuhan",
		"imbuhan": label.text,
		"path": get_path()
	}

func _can_drop_data(_pos, data):
	return false

func _notification(what):
	# Setelah drag selesai, hanya kembalikan visibilitas jika drop GAGAL
	if what == NOTIFICATION_DRAG_END and _dragging:
		if not _drop_succeeded:
			visible = true
		_dragging = false

# Fungsi baru yang dipanggil oleh panel target saat drop berhasil
func on_drop_successful():
	_drop_succeeded = true
