extends Control

@onready var option_panels = [
	$OptionsContainer/OptionA,
	$OptionsContainer/OptionB,
	$OptionsContainer/OptionC,
	$OptionsContainer/OptionD
]
@onready var imbuhan_panel: Panel = $Imbuhan
@onready var feedback_label: Label = $FeedbackLabel
@onready var question_label: Label = $QuestionLabel
@onready var options_parent: Control = $OptionsContainer
@onready var general_level := $General

@export var MATCH_SCORE = 34
var current_question := 0
var score := 0
var answer_selected := false
var selected_questions := []

var questions := [
	{"imbuhan":"me-","options":["menyontek","mensontek","mencontek","mecontek"],"answer_index":0, "explanation":"Bentuk baku: menyontek."},
	{"imbuhan":"ber-","options":["bermain","barmain","beramin","brmain"],"answer_index":0, "explanation":"Bentuk baku: bermain."},
	{"imbuhan":"ter-","options":["tertidur","tertidor","tertdur","tertidorr"],"answer_index":0, "explanation":"Bentuk baku: tertidur."},
	{"imbuhan":"di-","options":["dimasak","dimmasak","dimasaak","dimassak"],"answer_index":0, "explanation":"Bentuk baku: dimasak."},
	{"imbuhan":"ke-","options":["keindahan","keindhan","keindahn","kindahan"],"answer_index":0, "explanation":"Bentuk baku: keindahan."},
	{"imbuhan":"pe-","options":["petani","petanni","pettani","petanii"],"answer_index":0, "explanation":"Bentuk baku: petani."},
	{"imbuhan":"se-","options":["setinggi","setingi","setinggii","setngi"],"answer_index":0, "explanation":"Bentuk baku: setinggi."},
	{"imbuhan":"per-","options":["perlombaan","perlombean","perlomabaan","perlommbaan"],"answer_index":0, "explanation":"Bentuk baku: perlombaan."},
	{"imbuhan":"mem-","options":["memukul","memukull","memuukul","mmemukul"],"answer_index":0, "explanation":"Bentuk baku: memukul."},
	{"imbuhan":"men-","options":["menulis","menullis","mennulis","mennnulis"],"answer_index":0, "explanation":"Bentuk baku: menulis."}
]

func _ready() -> void:
	# ambil 5 soal acak
	var pool := questions.duplicate()
	pool.shuffle()
	selected_questions = pool.slice(0, 5)

	# hubungkan sinyal drop dari tiap panel (sekali saja)
	for i in range(option_panels.size()):
		if option_panels[i].has_method("set_index"):
			option_panels[i].call("set_index", i)
		if not option_panels[i].is_connected("dropped", Callable(self, "_on_option_dropped")):
			option_panels[i].connect("dropped", Callable(self, "_on_option_dropped"))

	show_question()

func show_question() -> void:
	answer_selected = false
	feedback_label.text = ""
	question_label.text = "Geser imbuhan ini ke kata yang benar!"

	# set imbuhan yang akan di-drag
	if imbuhan_panel.has_method("set_text"):
		imbuhan_panel.call("set_text", selected_questions[current_question]["imbuhan"])

	# tampilkan pilihan untuk soal saat ini
	var q = selected_questions[current_question]
	for i in range(option_panels.size()):
		var panel: Panel = option_panels[i]
		var lbl: Label = panel.get_node("Label")
		lbl.text = q["options"][i]
		panel.modulate = Color(1, 1, 1, 1)  # reset warna

func _on_option_dropped(index: int, imbuhan: String) -> void:
	_check_answer(index, imbuhan)

func _check_answer(index: int, dragged_imbuhan: String) -> void:
	if answer_selected:
		return
	answer_selected = true

	var q = selected_questions[current_question]
	var correct: int = q["answer_index"]

	if index == correct and dragged_imbuhan.strip_edges() == q["imbuhan"].strip_edges():
		score += 1
		general_level.add_score(MATCH_SCORE)
		feedback_label.text = "✅ Benar!"
		option_panels[index].modulate = Color(0, 1, 0, 1) # hijau
	else:
		feedback_label.text = "❌ Salah!\n" + q["explanation"]
		option_panels[index].modulate = Color(1, 0, 0, 1) # merah

	await get_tree().create_timer(1.0, false).timeout
	current_question += 1

	if current_question < selected_questions.size():
		show_question()
	else:
		game_over()

func game_over() -> void:
	question_label.text = "Permainan selesai!"
	imbuhan_panel.hide()
	options_parent.hide()
	feedback_label.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]
