extends Control

var current_question = 0
var score = 0
var answer_selected = false
var selected_questions = [] # Soal yang dipilih acak

var questions = [
	{
		"question": "Mereka mendaki gunung rinjani kemarin.",
		"options": ["Gunung Rinjani", "Gunung rinjani", "gunung Rinjani", "gunung rinjani"],
		"answer_index": 0
	},
	{
		"question": "Kami belajar sejarah kerajaan majapahit.",
		"options": ["Kerajaan Majapahit", "kerajaan Majapahit", "kerajaan majapahit", "Kerajaan majapahit"],
		"answer_index": 0
	},
	{
		"question": "Dia berkunjung ke pantai parangtritis.",
		"options": ["Pantai Parangtritis", "pantai Parangtritis", "pantai parangtritis", "Pantai parangtritis"],
		"answer_index": 0
	},
	{
		"question": "Kami mengunjungi candi borobudur saat liburan.",
		"options": ["Candi Borobudur", "Candi borobudur", "candi Borobudur", "candi borobudur"],
		"answer_index": 0
	},
	{
		"question": "Ayah membaca buku laskar pelangi.",
		"options": ["Laskar Pelangi", "Laskar pelangi", "laskar Pelangi", "laskar pelangi"],
		"answer_index": 0
	},
	{
		"question": "Mereka menonton film laskar pelangi.",
		"options": ["Laskar Pelangi", "Laskar pelangi", "laskar Pelangi", "laskar pelangi"],
		"answer_index": 0
	},
	{
		"question": "Budi pergi ke bandara soekarno-hatta.",
		"options": ["Bandara Soekarno-Hatta", "Bandara soekarno-hatta", "bandara Soekarno-Hatta", "bandara soekarno-hatta"],
		"answer_index": 0
	},
	{
		"question": "Siti membeli batik pekalongan.",
		"options": ["Batik Pekalongan", "Batik pekalongan", "batik Pekalongan", "batik pekalongan"],
		"answer_index": 0
	},
	{
		"question": "Mereka berkemah di taman nasional baluran.",
		"options": ["Taman Nasional Baluran", "Taman nasional Baluran", "taman Nasional Baluran", "taman nasional baluran"],
		"answer_index": 0
	},
	{
		"question": "Paman berlayar dari pelabuhan tanjung priok.",
		"options": ["Pelabuhan Tanjung Priok", "Pelabuhan tanjung priok", "pelabuhan Tanjung Priok", "pelabuhan tanjung priok"],
		"answer_index": 0
	}
]

# Variabel ini dideklarasikan tanpa onready
var option_buttons

func _ready():
	option_buttons = [
		$VBoxContainer/OptionA,
		$VBoxContainer/OptionB,
		$VBoxContainer/OptionC,
		$VBoxContainer/OptionD
	]
	
	# Ambil 5 soal acak dari 10
	selected_questions = questions.duplicate()
	selected_questions.shuffle()
	selected_questions = selected_questions.slice(0, 5)
	
	show_question()

func show_question():
	answer_selected = false
	#$NextButton.visible = false
	$FeedbackLabel.text = ""

	for button in option_buttons:
		button.disabled = false
		button.modulate = Color(1, 1, 1, 1)

	var q = selected_questions[current_question]
	$QuestionLabel.text = q["question"]
	for i in range(4):
		option_buttons[i].text = q["options"][i]

func _check_answer(index):
	if answer_selected:
		return

	answer_selected = true

	var correct_index = selected_questions[current_question]["answer_index"]
	
	if index == correct_index:
		$FeedbackLabel.text = "Benar!"
		score += 1
		option_buttons[index].modulate = Color(0, 1, 0, 1)
	else:
		$FeedbackLabel.text = "Salah!"
		option_buttons[index].modulate = Color(1, 0, 0, 1)
		option_buttons[correct_index].modulate = Color(0, 1, 0, 1)

	for button in option_buttons:
		button.disabled = true

	# Tunggu 1 detik lalu next
	await get_tree().create_timer(1.0).timeout
	current_question += 1
	if current_question < selected_questions.size():
		show_question()
	else:
		$QuestionLabel.text = "Permainan selesai!"
		$VBoxContainer.hide()
		$FeedbackLabel.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]


func _on_NextButton_pressed():
	current_question += 1
	if current_question < selected_questions.size():
		show_question()
	else:
		$QuestionLabel.text = "Permainan selesai!"
		$VBoxContainer.hide()
		$FeedbackLabel.text = "Skor kamu: %d dari %d" % [score, selected_questions.size()]
		$NextButton.hide()
		
func _on_option_a_pressed() -> void:
	_check_answer(0)

func _on_option_b_pressed() -> void:
	_check_answer(1)

func _on_option_c_pressed() -> void:
	_check_answer(2)

func _on_option_d_pressed() -> void:
	_check_answer(3)
