extends Panel

func can_drop_data(position, data):
	return typeof(data) == TYPE_STRING

func drop_data(position, data):
	get_parent().get_parent()._check_answer(get_option_index(), data)

func get_option_index():
	return get_parent().get_children().find(self)

func set_text(txt):
	$Label.text = txt

func get_text():
	return $Label.text
