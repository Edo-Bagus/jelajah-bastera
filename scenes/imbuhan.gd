extends Panel

@onready var label: Label = $Label

func set_text(txt: String) -> void:
	label.text = txt

# --- Drag ---
func _can_drag(at_position: Vector2) -> bool:
	return true  # panel ini bisa di-drag

func _get_drag_data(at_position: Vector2):
	var drag_data = label.text

	# buat preview drag
	var preview = Panel.new()
	preview.custom_minimum_size = Vector2(80, 40)
	var preview_label = Label.new()
	preview_label.text = label.text
	preview_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	preview_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	preview.add_child(preview_label)

	set_drag_preview(preview)
	return drag_data

# --- Drop ---
func _can_drop_data(at_position: Vector2, data) -> bool:
	return typeof(data) == TYPE_STRING

func _drop_data(at_position: Vector2, data) -> void:
	var main := get_tree().current_scene
	if main and main.has_method("_check_answer"):
		main._check_answer(-1, data)  # -1 = panel sumber
