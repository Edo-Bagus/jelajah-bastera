extends Panel
signal dropped(index: int, imbuhan: String)

@export var index: int = -1
@onready var label: Label = $Label

func set_index(i: int) -> void:
	index = i

func _can_drop_data(_pos, data) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.get("type", "") == "imbuhan"

func _drop_data(_pos, data) -> void:
	if index < 0:
		return
	var imb := str(data.get("imbuhan", ""))
	
	# Dapatkan referensi ke panel yang ditarik
	var source_node = get_node(data.path)
	if source_node and source_node.has_method("on_drop_successful"):
		# Beri tahu panel sumber bahwa drop berhasil
		source_node.on_drop_successful()
		# Panel sumber akan menyembunyikan dirinya sendiri di NOTIFICATION_DRAG_END

	emit_signal("dropped", index, imb)
