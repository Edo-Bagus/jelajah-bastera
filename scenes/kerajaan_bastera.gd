extends Control

const WordBoxScene := preload("res://components/word_box.tscn")

@onready var sources_container: VBoxContainer = $SourcesContainer
@onready var targets_container: VBoxContainer = $TargetsContainer
@onready var line_layer: Control = $LineLayer

var questions = [
	{"term": "Body Lotion", "match": "Handbody"},
	{"term": "Shampoo", "match": "Sampo"},
	{"term": "Lipstick", "match": "Pemerah Bibir"}
]

var active_line: Line2D = null
var drag_start_box: Control = null

func _ready():
	_load_game()

func _load_game():
	# bersihkan dulu
	for c in sources_container.get_children():
		c.queue_free()
	for c in targets_container.get_children():
		c.queue_free()
	# Perbaikan: Bersihkan anak-anak LineLayer dengan iterasi manual
	for c in line_layer.get_children():
		c.queue_free()

	# tampilkan kotak
	var idx = 0
	for q in questions:
		# Kotak padanan kata (sumber)
		var src_box = WordBoxScene.instantiate()
		src_box.is_source = true
		src_box.box_index = idx
		src_box.set_text(q["match"])
		sources_container.add_child(src_box)

		# Kotak istilah asing (target)
		var tgt_box = WordBoxScene.instantiate()
		tgt_box.is_source = false
		tgt_box.box_index = idx
		tgt_box.set_text(q["term"])
		targets_container.add_child(tgt_box)
		idx += 1

func _input(event):
	# update garis saat drag
	if active_line and event is InputEventMouseMotion:
		# Perbaikan: Menggunakan posisi mouse lokal relatif terhadap LineLayer
		active_line.set_point_position(1, line_layer.get_local_mouse_position())

func _on_box_dropped(target_box: Control, data: Dictionary):
	var source_index = data["index"]
	var target_index = target_box.box_index

	# hapus garis aktif sementara
	if active_line:
		active_line.queue_free()
		active_line = null

	var src_box = sources_container.get_child(source_index)
	var src_pos = _get_box_center(src_box)
	var tgt_pos = _get_box_center(target_box)

	if source_index == target_index:
		# benar → buat garis tetap
		_make_line(src_pos, tgt_pos, Color.GREEN)
	else:
		# salah → garis merah sementara
		var temp_line = _make_line(src_pos, tgt_pos, Color.RED)
		await get_tree().create_timer(0.8).timeout
		if is_instance_valid(temp_line):
			temp_line.queue_free()

func _get_box_center(box: Control) -> Vector2:
	# Menggunakan global_position untuk mendapatkan posisi absolut, lalu menguranginya
	return box.get_global_rect().get_center() - global_position

func _make_line(p1: Vector2, p2: Vector2, color: Color) -> Line2D:
	var line = Line2D.new()
	line.width = 4
	line.default_color = color
	line.add_point(p1)
	line.add_point(p2)
	line_layer.add_child(line)
	return line

func _start_drag_from_box(box: Control):
	drag_start_box = box
	active_line = Line2D.new()
	active_line.width = 4
	active_line.default_color = Color.YELLOW
	# Titik awal garis
	active_line.add_point(_get_box_center(box))
	# Titik kedua garis, akan mengikuti kursor
	active_line.add_point(_get_box_center(box))
	line_layer.add_child(active_line)
