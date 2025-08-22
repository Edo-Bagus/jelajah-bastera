extends Panel

@onready var label: Label = $Label
var _dragging := false

func set_text(txt: String) -> void:
	label.text = txt

func _get_drag_data(at_position):
	# --- Buat label preview ---
	var preview_label := Label.new()
	preview_label.text = label.text
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_size_override("font_size", 30)
	preview_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_label.offset_left = 0
	preview_label.offset_top = 0
	preview_label.offset_right = 0
	preview_label.offset_bottom = 0

	# --- Buat panel preview & salin style override dari panel asli ---
	var preview := Panel.new()
	preview.custom_minimum_size = size            # samakan ukuran
	preview.modulate = modulate                   # samakan modulate

	# Coba ambil style override khusus panel ini dulu
	var style_override = get("res://scenes/gunung ragabasa/panel.tres")
	if style_override:
		preview.add_theme_stylebox_override("panel", style_override.duplicate(true))
	else:
		# fallback ke style dari theme aktif
		var base_style := get_theme_stylebox("panel")
		if base_style:
			preview.add_theme_stylebox_override("panel", base_style.duplicate(true))

	preview.add_child(preview_label)

	# Tampilkan preview saat drag
	set_drag_preview(preview)

	# Sembunyikan panel asli supaya terlihat "pindah"
	visible = false
	_dragging = true

	return {
		"type": "imbuhan",
		"imbuhan": label.text,
		# kirim path kalau suatu saat target ingin mereferensi node asli
		"path": get_path()
	}

func _can_drop_data(_pos, data):
	return false # Imbuhan tidak menerima drop

func _notification(what):
	# Setelah drag selesai (apapun hasilnya), pastikan panel muncul lagi
	if what == NOTIFICATION_DRAG_END and _dragging:
		visible = true
		_dragging = false
