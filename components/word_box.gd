extends Control

@export var box_index: int = -1
@export var is_source: bool = false   # true kalau kotak istilah asing (target drop)
@onready var label_node: Label = $word_label

func set_text(txt: String) -> void:
	$word_label.text = txt

func _get_drag_data(at_position):
	if not is_source:
		# hanya kotak padanan (bukan target) yang bisa di-drag
		return null

	var drag_data = {"text": label_node.text, "index": box_index}

	# Preview drag
	var preview = duplicate()
	set_drag_preview(preview)
	return drag_data

func can_drop_data(pos, data) -> bool:
	return not is_source and typeof(data) == TYPE_DICTIONARY and data.has("index")

func drop_data(pos, data) -> void:
	if get_tree().current_scene.has_method("_on_box_dropped"):
		get_tree().current_scene._on_box_dropped(self, data)
