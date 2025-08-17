extends Panel

@onready var label_node: Label = $option_label

@export var option_index: int = -1
@export var correct_imbuhan: String = ""

func set_text(txt: String) -> void:
	$option_label.text = txt

func _can_drop_data(_pos, data: Variant) -> bool:
	# Saat hover, kalau data valid → highlight abu-abu
	if typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "imbuhan":
		modulate = Color(0.8, 0.8, 0.8, 1) # abu-abu terang
		return true
	return false

func _drop_data(_pos, data: Variant) -> void:
	modulate = Color(1, 1, 1, 1) # reset sebelum pengecekan
	if typeof(data) == TYPE_DICTIONARY and data.has("imbuhan"):
		if get_tree().current_scene.has_method("_check_answer"):
			get_tree().current_scene.call("_check_answer", option_index, data["imbuhan"])
