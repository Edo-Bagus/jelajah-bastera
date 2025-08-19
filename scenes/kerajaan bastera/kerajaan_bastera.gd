extends Control

@onready var question_panel: Panel = $QuestionPanel
@onready var options: Array = $OptionsContainer.get_children()
@onready var line_layer: Node2D = $LineDrawer   # Pastikan node LineDrawer ada di scene
@onready var q_label: Label = $QuestionPanel/Label
@onready var general_level = $General

@export var MATCH_SCORE = 34

var questions := [
	{"q":"Ibu kota Indonesia?",         "opts":["Jakarta","Surabaya","Medan","Bandung"], "answer":0},
	{"q":"2 + 2 = ?",                   "opts":["3","4","5","6"],                       "answer":1},
	{"q":"Planet terbesar?",            "opts":["Mars","Venus","Jupiter","Merkurius"],  "answer":2},
	{"q":"Bendera Indonesia?",          "opts":["Merah Putih","Biru Putih","Merah Hijau","Kuning Hijau"], "answer":0},
	{"q":"Mesin game ini pakai bahasa?","opts":["Python","GDScript","Java","C++"],      "answer":1}
]

var current_question := 0
var dragging := false
var rope: Line2D = null
var locked := false   # 🔒 kalau sudah drop, tali & panel terkunci

func _ready() -> void:
	_load_question()

func _load_question() -> void:
	# HAPUS semua tali lama
	for c in line_layer.get_children():
		c.queue_free()

	dragging = false
	locked = false
	var q = questions[current_question]
	q_label.text = q["q"]

	# set teks option
	for i in range(options.size()):
		var lbl: Label = options[i].get_node("Label")
		lbl.text = q["opts"][i]
		options[i].modulate = Color(1,1,1,1)  # reset warna

func _input(event: InputEvent) -> void:
	if locked:  # ❌ kalau sudah terkunci, jangan bisa drag lagi
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			# MULAI hanya jika klik di QuestionPanel
			if question_panel.get_global_rect().has_point(event.position):
				dragging = true
				rope = Line2D.new()
				rope.width = 6
				rope.default_color = Color(1,1,1,1)  # putih saat drag
				# Bisa pakai tekstur tali
				# rope.texture = preload("res://assets/rope.png")
				# rope.texture_mode = Line2D.LINE_TEXTURE_TILE
				rope.add_point(question_panel.get_global_rect().get_center())
				rope.add_point(event.position)
				line_layer.add_child(rope)
		else:
			# LEPAS: cek apakah di atas salah satu option
			if dragging:
				var connected := false
				for i in range(options.size()):
					if options[i].get_global_rect().has_point(event.position):
						connected = true
						locked = true   # 🔒 kunci supaya tidak bisa drag lagi
						
						# cek jawaban
						var correct_i: int = questions[current_question]["answer"]
						var is_correct := (i == correct_i)
						var color = Color.GREEN if is_correct else Color.RED
						
						if is_correct:
							general_level.add_score(MATCH_SCORE)

						# ubah warna tali & tempelkan ujung ke tengah option
						rope.default_color = color
						rope.set_point_position(1, options[i].get_global_rect().get_center())

						# highlight option terpilih
						options[i].modulate = color

						# tampilkan sebentar lalu next
						await get_tree().create_timer(1.2, false).timeout
						_next_question()
						break

				# Jika tidak konek ke option manapun: hapus tali (reset)
				if not connected and rope:
					rope.queue_free()

				dragging = false

	elif event is InputEventMouseMotion and dragging and rope:
		# geser ujung tali mengikuti mouse saat drag
		rope.set_point_position(1, event.position)

func _next_question() -> void:
	current_question += 1
	if current_question < questions.size():
		_load_question()
	else:
		q_label.text = "Selesai!"
		for i in range(options.size()):
			options[i].get_node("Label").text = ""
