extends Control

@onready var question_panel: Panel = $QuestionPanel
@onready var options: Array = $OptionsContainer.get_children()
@onready var line_layer: Node2D = $LineDrawer
@onready var q_label: Label = $QuestionPanel/Label
@onready var general_level = $General

@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound

@export var MATCH_SCORE = 34

# URL JSON soal (nanti isi dengan link Supabase kamu)
const SOAL_URL := "https://kcrglneppkjtdoatdvzr.supabase.co/storage/v1/object/public/BankSoal/bank_soal_asli.json"

var selected_questions := []
var current_question := 0
var dragging := false
var rope: Line2D = null
var locked := false

var color : Color
var http_request: HTTPRequest

func _ready() -> void:
	Global.play_music(preload("res://assets/Sound/desa eja.mp3"))
	Global.music_player.stream.loop = true
	# buat node HTTPRequest lewat kode
	general_level._show_loading("Loading")
	general_level.level = 5
	
	http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_HTTPRequest_request_completed)

	# fetch soal dari URL
	if SOAL_URL != "":
		http_request.request(SOAL_URL)
	else:
		q_label.text = "Belum ada link soal!"

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	if response_code != 200:
		q_label.text = "Gagal memuat soal!"
		return

	var json = JSON.parse_string(body.get_string_from_utf8())
	if typeof(json) != TYPE_ARRAY:
		q_label.text = "Format soal tidak valid!"
		return

	general_level._hide_loading()
	
	selected_questions = json
	selected_questions.shuffle()
	current_question = 0
	_load_question()

func _load_question() -> void:
	# hapus tali lama
	for c in line_layer.get_children():
		c.queue_free()

	dragging = false
	locked = false

	var q = selected_questions[current_question]
	q_label.text = q["q"]

	# acak opsi
	q["opts"].shuffle()
	selected_questions[current_question] = q

	for i in range(options.size()):
		var lbl: Label = options[i].get_node("Label")
		lbl.text = q["opts"][i]["text"]
		options[i].set_meta("is_answer", q["opts"][i]["is_answer"])
		options[i].modulate = Color(1,1,1,1)

func _input(event: InputEvent) -> void:
	if locked:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			if question_panel.get_global_rect().has_point(event.position):
				dragging = true
				rope = Line2D.new()
				rope.width = 6
				rope.default_color = Color(1,1,1,1)
				rope.add_point(question_panel.get_global_rect().get_center())
				rope.add_point(event.position)
				line_layer.add_child(rope)
		else:
			if dragging:
				var connected := false
				for i in range(options.size()):
					if options[i].get_global_rect().has_point(event.position):
						connected = true
						locked = true
					
						var is_correct: bool = options[i].get_meta("is_answer")
						
						if is_correct : 
							color = Color.GREEN
							click_sound.play()
						else :
							color = Color.RED
							wrong_sound.play()

						if is_correct:
							general_level.add_score(MATCH_SCORE)

						rope.default_color = color
						rope.set_point_position(1, options[i].get_global_rect().get_center())
						options[i].modulate = color

						await get_tree().create_timer(1.2, false).timeout
						_next_question()
						break

				if not connected and rope:
					rope.queue_free()

				dragging = false

	elif event is InputEventMouseMotion and dragging and rope:
		rope.set_point_position(1, event.position)

func _next_question() -> void:
	current_question += 1
	if current_question < selected_questions.size():
		_load_question()
	else:
		q_label.text = "Selesai!"
		for i in range(options.size()):
			options[i].get_node("Label").text = ""
