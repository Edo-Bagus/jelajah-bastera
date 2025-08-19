extends Popup

@export var star_on: Texture2D
@export var star_off: Texture2D
@export var home_icon: Texture2D
@export var next_icon: Texture2D
@export var replay_icon: Texture2D

@onready var stars = [$Panel/Stars/Star1, $Panel/Stars/Star2, $Panel/Stars/Star3]
@onready var score_bar: TextureProgressBar = $Panel/ScoreBar
@onready var btn_home: Button = $Panel/Buttons/Home
@onready var btn_next: Button = $Panel/Buttons/Next
@onready var btn_replay: Button = $Panel/Buttons/Replay

signal home_pressed
signal next_pressed
signal replay_pressed

func _ready():
	$Panel/Buttons/Home.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/Buttons/Next.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/Buttons/Replay.process_mode = Node.PROCESS_MODE_ALWAYS
	btn_home.icon = home_icon
	btn_next.icon = next_icon
	btn_replay.icon = replay_icon

	btn_home.pressed.connect(func(): emit_signal("home_pressed"))
	btn_next.pressed.connect(func(): emit_signal("next_pressed"))
	btn_replay.pressed.connect(func(): emit_signal("replay_pressed"))

func show_result(score: float, max_score: float):
	# hitung jumlah bintang (misal 1 bintang tiap 33%)
	var percent = score / max_score
	var star_count = int(round(percent * 3))

	for i in range(3):
		stars[i].texture = star_on if i < star_count else star_off

	score_bar.min_value = 0
	score_bar.max_value = max_score
	score_bar.value = score

	popup_centered()
	get_tree().paused = true
	
func _on_home_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/main menu/main_menu.tscn")

func _on_next_pressed():
	get_tree().paused = false
	get_tree().change_scene_to_file("res://scenes/peta/peta.tscn")

func _on_replay_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()
