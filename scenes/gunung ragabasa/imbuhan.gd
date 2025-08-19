extends Panel

@onready var label: Label = $Label

func set_text(txt: String) -> void:
	label.text = txt

func _get_drag_data(at_position):
	var preview_label = Label.new()
	preview_label.text = label.text
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview_label.add_theme_font_size_override("font_size", 30)
	preview_label.set_anchors_preset(Control.PRESET_FULL_RECT)
	preview_label.offset_left = 0
	preview_label.offset_top = 0
	preview_label.offset_right = 0
	preview_label.offset_bottom = 0

	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(300, 100)
	preview.add_child(preview_label)

	set_drag_preview(preview)

	print("drag data")
	return {
		"type": "imbuhan",
		"imbuhan": label.text
	}

func _can_drop_data(_pos, data):
	return false # Imbuhan tidak menerima drop
