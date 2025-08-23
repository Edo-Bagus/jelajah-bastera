extends Control

@onready var option_panels = [
	$OptionA,
	$OptionB,
	$OptionC,
	$OptionD
]
@onready var imbuhan_panel: Panel = $Imbuhan # Kembali menggunakan @onready
@onready var feedback_label: Label = $FeedbackLabel
@onready var question_label: Label = $QuestionLabel
@onready var general_level := $General
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var http_request: HTTPRequest = HTTPRequest.new()

@export var MATCH_SCORE = 34
var current_question := 0
var score := 0
var answer_selected := false
var selected_questions := []
var questions := []

const SOAL_URL = "https://kcrglneppkjtdoatdvzr.supabase.co/storage/v1/object/public/BankSoal/soal_imbuhan.json"

func _ready() -> void:
	Global.play_music(preload("res://assets/Sound/ragabasa.mp3"))
	Global.music_player.stream.loop = true
	general_level.level = 4
	add_child(http_request)
	http_request.request_completed.connect(_on_http_request_completed)
	http_request.request(SOAL_URL)

func _on_http_request_completed(result, response_code, headers, body):
	if response_code != 200:
		question_label.text = "Gagal memuat soal!"
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) == TYPE_ARRAY:
		questions = json
	else:
		question_label.text = "Format soal tidak valid!"
		return

	selected_questions = questions.duplicate()
	selected_questions.shuffle()

	for i in range(option_panels.size()):
		if option_panels[i].has_method("set_index"):
			option_panels[i].call("set_index", i)
		if not option_panels[i].is_connected("dropped", Callable(self, "_on_option_dropped")):
			option_panels[i].connect("dropped", Callable(self, "_on_option_dropped"))

	show_question()

func show_question() -> void:
	answer_selected = false
	feedback_label.text = ""
	question_label.text = "Tempel kertas imbuhan ini ke papan yang sesuai !"

	# Tampilkan kembali panel imbuhan
	imbuhan_panel.show()
	
	# Reset posisi ke tempat semula
	imbuhan_panel.position = Vector2(390, 400) # sesuaikan dengan posisi awal panel Anda

	if imbuhan_panel.has_method("set_text"):
		imbuhan_panel.call("set_text", selected_questions[current_question]["imbuhan"])

	var q = selected_questions[current_question]
	q["options"].shuffle()

	for i in range(option_panels.size()):
		var panel: Panel = option_panels[i]
		var lbl: Label = panel.get_node("Label")
		lbl.text = q["options"][i]["text"]
		panel.set_meta("is_answer", q["options"][i]["is_answer"])
		panel.modulate = Color(1, 1, 1, 1)

func _on_option_dropped(index: int, imbuhan: String) -> void:
	_check_answer(index, imbuhan)

func _check_answer(index: int, dragged_imbuhan: String) -> void:
	if answer_selected:
		return
	answer_selected = true

	var q = selected_questions[current_question]
	var panel: Panel = option_panels[index]
	var is_correct = panel.get_meta("is_answer")

	if is_correct and dragged_imbuhan.strip_edges() == q["imbuhan"].strip_edges():
		score += 1
		general_level.add_score(MATCH_SCORE)
		feedback_label.text = "✅ Benar!"
		panel.modulate = Color(0, 1, 0, 1)
		click_sound.play()
	else:
		feedback_label.text = "❌ Salah!"
		panel.modulate = Color(1, 0, 0, 1)
		wrong_sound.play()

	await get_tree().create_timer(1.0, false).timeout
	current_question += 1

	if current_question < selected_questions.size():
		show_question()
	else:
		game_over()

func game_over() -> void:
	question_label.text = "Permainan selesai!"
	imbuhan_panel.hide()
	feedback_label.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]
