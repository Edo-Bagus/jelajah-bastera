extends Button

@onready var tutorial_menu = get_tree().get_root().find_child("TutorialMenu", true, false)

func _ready():
	if not tutorial_menu:
		push_warning("TutorialMenu not found in scene tree!")

func _on_pressed():
	if tutorial_menu:
		tutorial_menu.show_menu()
