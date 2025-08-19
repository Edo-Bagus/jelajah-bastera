extends TextureButton

@onready var pause_menu = get_tree().get_root().find_child("PauseMenu", true, false)

func _ready():
	if not pause_menu:
		push_warning("PauseMenu not found in scene tree!")

func _on_pressed():
	if pause_menu:
		pause_menu.show_menu()
