extends Control

signal resume_pressed
signal back_pressed

func _ready():
	$Close.process_mode = Node.PROCESS_MODE_ALWAYS
	visible = false

func show_menu():
	get_tree().paused = true
	visible = true

func hide_menu():
	get_tree().paused = false
	visible = false
	
func _on_Close_pressed():
	hide_menu()
	emit_signal("resume_pressed")
