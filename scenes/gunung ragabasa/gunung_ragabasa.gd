extends Control

@onready var option_panels = [
	$OptionA,
	$OptionB,
	$OptionC,
	$OptionD
]
@onready var imbuhan_panel: Panel = $Imbuhan
@onready var feedback_label: Label = $FeedbackLabel
@onready var question_label: Label = $QuestionLabel
#@onready var options_parent: Control = $OptionsContainer
@onready var general_level := $General

@export var MATCH_SCORE = 34
var current_question := 0
var score := 0
var answer_selected := false
var selected_questions := []

# data soal baru: options pakai array of dict {text, is_answer}
var questions := [
	{"imbuhan":"me-","options":[
		{"text":"menyontek","is_answer":true},
		{"text":"mensontek","is_answer":false},
		{"text":"mencontek","is_answer":false},
		{"text":"mecontek","is_answer":false}
	]},
	{"imbuhan":"ber-","options":[
		{"text":"bermain","is_answer":true},
		{"text":"barmain","is_answer":false},
		{"text":"beramin","is_answer":false},
		{"text":"brmain","is_answer":false}
	]},
	{"imbuhan":"ter-","options":[
		{"text":"tertidur","is_answer":true},
		{"text":"tertidor","is_answer":false},
		{"text":"tertdur","is_answer":false},
		{"text":"tertidorr","is_answer":false}
	]},
	{"imbuhan":"di-","options":[
		{"text":"dimasak","is_answer":true},
		{"text":"dimmasak","is_answer":false},
		{"text":"dimasaak","is_answer":false},
		{"text":"dimassak","is_answer":false}
	]},
	{"imbuhan":"ke-","options":[
		{"text":"keindahan","is_answer":true},
		{"text":"keindhan","is_answer":false},
		{"text":"keindahn","is_answer":false},
		{"text":"kindahan","is_answer":false}
	]},
	{"imbuhan":"pe-","options":[
		{"text":"petani","is_answer":true},
		{"text":"petanni","is_answer":false},
		{"text":"pettani","is_answer":false},
		{"text":"petanii","is_answer":false}
	]},
	{"imbuhan":"se-","options":[
		{"text":"setinggi","is_answer":true},
		{"text":"setingi","is_answer":false},
		{"text":"setinggii","is_answer":false},
		{"text":"setngi","is_answer":false}
	]},
	{"imbuhan":"per-","options":[
		{"text":"perlombaan","is_answer":true},
		{"text":"perlombean","is_answer":false},
		{"text":"perlomabaan","is_answer":false},
		{"text":"perlommbaan","is_answer":false}
	]},
	{"imbuhan":"mem-","options":[
		{"text":"memukul","is_answer":true},
		{"text":"memukull","is_answer":false},
		{"text":"memuukul","is_answer":false},
		{"text":"mmemukul","is_answer":false}
	]},
	{"imbuhan":"men-","options":[
		{"text":"menulis","is_answer":true},
		{"text":"menullis","is_answer":false},
		{"text":"mennulis","is_answer":false},
		{"text":"mennnulis","is_answer":false}
	]}
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

	# tampilkan pilihan untuk soal saat ini (acak urutannya)
	var q = selected_questions[current_question]
	q["options"].shuffle()

	for i in range(option_panels.size()):
		var panel: Panel = option_panels[i]
		var lbl: Label = panel.get_node("Label")
		lbl.text = q["options"][i]["text"]
		panel.set_meta("is_answer", q["options"][i]["is_answer"])
		panel.modulate = Color(1, 1, 1, 1)  # reset warna

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
		panel.modulate = Color(0, 1, 0, 1) # hijau
	else:
		feedback_label.text = "❌ Salah!"
		panel.modulate = Color(1, 0, 0, 1) # merah

	await get_tree().create_timer(1.0, false).timeout
	current_question += 1

	if current_question < selected_questions.size():
		show_question()
	else:
		game_over()

func game_over() -> void:
	question_label.text = "Permainan selesai!"
	imbuhan_panel.hide()
	#options_parent.hide()
	feedback_label.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]
