extends Control

@onready var general_level = $General
@onready var http_request: HTTPRequest = $HTTPRequest   # Tambahkan node HTTPRequest di scene

@export var MATCH_SCORE = 33
var current_question = 0
var score = 0
var answer_selected = false
var selected_questions = [] 
var current_options = []   # opsi untuk soal yang sedang tampil (sudah diacak)
var questions = []   # Akan diisi dari JSON fetch
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var question_label: Label = $Soal/QuestionLabel

# variabel option button
var option_buttons

# URL JSON soal kamu
const SOAL_URL = "https://kcrglneppkjtdoatdvzr.supabase.co/storage/v1/object/public/BankSoal/soal_desaeja.json"

func _ready():
	Global.play_music(preload("res://assets/Sound/desa eja.mp3"))
	Global.music_player.stream.loop = true
	option_buttons = [
		$VBoxContainer/OptionA,
		$VBoxContainer/OptionB,
		$VBoxContainer/OptionC,
		$VBoxContainer/OptionD
	]
	
	general_level._show_loading("Loading")
	general_level.level = 3
	
	# fetch data soal dari Supabase
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_HTTPRequest_request_completed)

	# fetch soal
	http_request.request(SOAL_URL)


func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		question_label.text = "Gagal memuat soal!"
		return
	
	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) == TYPE_ARRAY:
		questions = json
	else:
		question_label.text = "Format soal tidak valid!"
		return
	
	general_level._hide_loading()
	# ambil 5 soal acak
	selected_questions = questions.duplicate()
	selected_questions.shuffle()
	
	show_question()


func show_question():
	# reset state
	answer_selected = false
	$FeedbackLabel.text = ""

	var q = selected_questions[current_question]
	question_label.text = q["question"]

	# acak options, simpan ke current_options
	current_options = q["options"].duplicate()
	current_options.shuffle()

	# reset semua tombol dan label
	for i in range(option_buttons.size()):
		var btn: TextureButton = option_buttons[i]
		var lbl: Label = btn.get_node("Label")
		lbl.text = current_options[i]["text"]
		btn.disabled = false
		btn.modulate = Color(1, 1, 1, 1)
		lbl.modulate = Color(1, 1, 1, 1)


func _check_answer(index):
	if answer_selected:
		return

	answer_selected = true
	var chosen = current_options[index]

	var btn: TextureButton = option_buttons[index]
	var lbl: Label = btn.get_node("Label")

	if chosen["is_answer"]:
		$FeedbackLabel.text = "Benar!"
		score += 1
		general_level.add_score(MATCH_SCORE)
		btn.modulate = Color(0, 1, 0, 0.7)
		lbl.modulate = Color(0, 1, 0, 1)
		click_sound.play()
	else:
		$FeedbackLabel.text = "Salah!"
		btn.modulate = Color(1, 0, 0, 0.7)
		lbl.modulate = Color(1, 0, 0, 1)
		wrong_sound.play()
		# highlight jawaban benar
		for i in range(current_options.size()):
			if current_options[i]["is_answer"]:
				var correct_btn: TextureButton = option_buttons[i]
				var correct_lbl: Label = correct_btn.get_node("Label")
				correct_btn.modulate = Color(0, 1, 0, 0.7)
				correct_lbl.modulate = Color(0, 1, 0, 1)
				break

	# disable semua tombol setelah jawab
	for button in option_buttons:
		button.disabled = true

	# tunggu sebentar sebelum next
	await get_tree().create_timer(1.0).timeout

	# 🔑 Cek lagi supaya timer lama gak “auto skip”
	if not answer_selected:
		return

	current_question += 1
	if current_question < selected_questions.size():
		show_question()
	else:
		question_label.text = "Permainan selesai!"
		$VBoxContainer.hide()
		$FeedbackLabel.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]



func _on_NextButton_pressed():
	current_question += 1
	if current_question < selected_questions.size():
		show_question()
	else:
		question_label.text = "Permainan selesai!"
		$VBoxContainer.hide()
		$FeedbackLabel.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]
		$NextButton.hide()


func _on_option_a_pressed() -> void:
	_check_answer(0)
	#click_sound.play()

func _on_option_b_pressed() -> void:
	_check_answer(1)
	#click_sound.play()

func _on_option_c_pressed() -> void:
	_check_answer(2)
	#click_sound.play()

func _on_option_d_pressed() -> void:
	_check_answer(3)
	#click_sound.play()
