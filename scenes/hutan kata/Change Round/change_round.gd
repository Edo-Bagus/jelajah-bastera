extends Control

@export var star_on: Texture2D
@export var star_off: Texture2D

@onready var stars = [$Panel/Stars/Star1, $Panel/Stars/Star2, $Panel/Stars/Star3]
@onready var score_bar: TextureProgressBar = $Panel/ScoreBar
@onready var btn_home := $Panel/Buttons/Home
@onready var btn_next := $Panel/Buttons/Next
@onready var btn_replay := $Panel/Buttons/Replay
@onready var icon: TextureRect = $Panel/Icon

signal home_pressed
signal next_pressed
signal replay_pressed

func _ready():
	# pastikan tombol tetap aktif walau game paused
	btn_home.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_next.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_replay.process_mode = Node.PROCESS_MODE_ALWAYS

	btn_home.pressed.connect(func(): emit_signal("home_pressed"))
	btn_next.pressed.connect(func(): emit_signal("next_pressed"))
	btn_replay.pressed.connect(func(): emit_signal("replay_pressed"))

	# awalnya disembunyikan
	hide()

func show_result(score: float, max_score: float):
	# hitung jumlah bintang (misal 1 bintang tiap 33%)
	var percent = score / max_score
	var star_count = int(round(percent * 3))

	for i in range(3):
		stars[i].texture = star_on if i < star_count else star_off

	score_bar.min_value = 0
	score_bar.max_value = max_score
	score_bar.value = score
	
	update_icon_position()
	# tampilkan dan center manual
	show()
	global_position = (get_viewport_rect().size - size) / 2

	# pause game
	get_tree().paused = true
	

func update_icon_position():
	var ratio = 0.0
	if score_bar.max_value > score_bar.min_value:
		ratio = (score_bar.value - score_bar.min_value) / (score_bar.max_value - score_bar.min_value)

	# hitung posisi di dalam bar
	var bar_rect = score_bar.get_rect()
	var start_x = score_bar.global_position.x + 35
	var end_x = start_x + bar_rect.size.x - 70

	var new_x = lerp(start_x, end_x, ratio) - icon.size.x / 2
	icon.global_position = Vector2(new_x, icon.global_position.y)


func _on_home_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")

func _on_next_pressed():
	get_tree().paused = false
	hide()

func _on_replay_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
