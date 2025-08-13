extends Control

const OptionScene := preload("res://components/option.tscn")

@onready var options_container: GridContainer = $OptionsContainer
@onready var imbuhan_panel: Panel = $Imbuhan
@onready var feedback_label: Label = $FeedbackLabel
@onready var question_label: Label = $QuestionLabel

var current_question := 0
var score := 0
var answer_selected := false
var selected_questions := []

var questions := [
	{"imbuhan":"me-","options":["menyontek","mensontek","mencontek","mecontek"],"answer_index":0,
	 "explanation":"Bentuk baku: menyontek."},
	{"imbuhan":"ber-","options":["bermain","barmain","beramin","brmain"],"answer_index":0,
	 "explanation":"Bentuk baku: bermain."},
	{"imbuhan":"ter-","options":["tertidur","tertidor","tertdur","tertidorr"],"answer_index":0,
	 "explanation":"Bentuk baku: tertidur."},
	{"imbuhan":"di-","options":["dimasak","dimmasak","dimasaak","dimassak"],"answer_index":0,
	 "explanation":"Bentuk baku: dimasak."},
	{"imbuhan":"ke-","options":["keindahan","keindhan","keindahn","kindahan"],"answer_index":0,
	 "explanation":"Bentuk baku: keindahan."},
	{"imbuhan":"pe-","options":["petani","petanni","pettani","petanii"],"answer_index":0,
	 "explanation":"Bentuk baku: petani."},
	{"imbuhan":"se-","options":["setinggi","setingi","setinggii","setngi"],"answer_index":0,
	 "explanation":"Bentuk baku: setinggi."},
	{"imbuhan":"per-","options":["perlombaan","perlombean","perlomabaan","perlommbaan"],"answer_index":0,
	 "explanation":"Bentuk baku: perlombaan."},
	{"imbuhan":"mem-","options":["memukul","memukull","memuukul","mmemukul"],"answer_index":0,
	 "explanation":"Bentuk baku: memukul."},
	{"imbuhan":"men-","options":["menulis","menullis","mennulis","mennnulis"],"answer_index":0,
	 "explanation":"Bentuk baku: menulis."}
]

func _ready() -> void:
	# Pastikan grid punya kolom yang cukup
	if options_container.columns == 0:
		options_container.columns = 2

	# Pilih 5 soal acak
	var pool := questions.duplicate()
	pool.shuffle()
	selected_questions = pool.slice(0, 5)

	show_question()

func show_question() -> void:
	answer_selected = false
	feedback_label.text = ""
	question_label.text = "Geser imbuhan ini ke kata yang benar!"

	# Set teks imbuhan (menggunakan script di Imbuhan.gd)
	if imbuhan_panel.has_method("set_text"):
		imbuhan_panel.call("set_text", selected_questions[current_question]["imbuhan"])

	# Bersihkan opsi lama
	for child in options_container.get_children():
		child.queue_free()

	# Tambahkan opsi baru
	var q = selected_questions[current_question]
	for i in range(q["options"].size()):
		var opt: Panel = OptionScene.instantiate()
		opt.set_text(q["options"][i])
		opt.option_index = i
		opt.correct_imbuhan = q["imbuhan"] # dipakai untuk perbandingan di drop_data
		opt.modulate = Color(1, 1, 1, 1) # reset warna
		options_container.add_child(opt)

func _check_answer(index: int, dragged_imbuhan: String) -> void:
	if answer_selected:
		return
	answer_selected = true

	var q = selected_questions[current_question]
	var correct: int = q["answer_index"]

	if index == correct and dragged_imbuhan == q["imbuhan"]:
		score += 1
		feedback_label.text = "✅ Benar!"
	else:
		feedback_label.text = "❌ Salah!\n" + q["explanation"]

	await get_tree().create_timer(1.2).timeout
	current_question += 1

	if current_question < selected_questions.size():
		show_question()
	else:
		game_over()

func game_over() -> void:
	question_label.text = "Permainan selesai!"
	imbuhan_panel.hide()
	options_container.hide()
	feedback_label.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]
