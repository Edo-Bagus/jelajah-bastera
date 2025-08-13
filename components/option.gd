extends Panel

var option_index: int = -1
var correct_imbuhan: String = ""
@onready var label: Label = $Label

func set_text(txt: String) -> void:
	$Label.text = txt

func can_drop_data(_pos, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("type") and data["type"] == "imbuhan"

func drop_data(_pos, data) -> void:
	var main := get_tree().current_scene
	if main and main.has_method("_check_answer"):
		main._check_answer(option_index, data)
