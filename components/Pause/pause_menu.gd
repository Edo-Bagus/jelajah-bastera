extends Control

signal resume_pressed
signal back_pressed

func _ready():
	visible = false
	$VBoxContainer/Resume.process_mode = Node.PROCESS_MODE_ALWAYS
	$VBoxContainer/Quit.process_mode = Node.PROCESS_MODE_ALWAYS


func show_menu():
	get_tree().paused = true
	visible = true

func hide_menu():
	get_tree().paused = false
	visible = false

func _on_ResumeButton_pressed():
	hide_menu()
	emit_signal("resume_pressed")

func _on_BackToMapButton_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/peta/peta.tscn")
	emit_signal("back_pressed")
