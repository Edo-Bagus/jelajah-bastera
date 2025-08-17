extends Panel
signal dropped(index: int, imbuhan: String)

@export var index: int = -1
@onready var label: Label = $Label  # hanya untuk tampilan (jangan diubah saat drop)

func set_index(i: int) -> void:
	index = i

func _can_drop_data(_pos, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("type", "") == "imbuhan"

func _drop_data(_pos, data) -> void:
	if index < 0:
		return
	var imb := str(data.get("imbuhan", ""))
	emit_signal("dropped", index, imb)
