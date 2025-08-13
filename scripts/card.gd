extends Button

## Public property yang bisa diisi dari luar
@export var word: String = ""
var is_flipped := false
var is_matched := false

func _ready():
	$"Front Label".text = word
	update_display()

func flip():
	if is_matched: return
	is_flipped = not is_flipped
	update_display()

func reveal():
	is_flipped = true
	update_display()

func hide_card():
	is_flipped = false
	update_display()

func mark_matched():
	is_matched = true
	disabled = true
	modulate = Color(1, 1, 1, 0.5)  # Buat tampak pudar sebagai tanda matched
	update_display()

func update_display():
	if is_flipped or is_matched:
		$"Front Label".text = word
	else:
		$"Front Label".text = ""
