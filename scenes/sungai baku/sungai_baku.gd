extends Control

@export var batu_scene: PackedScene
@export var spawn_positions: Array[Vector2]       # 2 posisi target di layar
@export var spawn_out_positions: Array[Vector2]   # 2 posisi awal (misal kiri dan kanan)
@export var move_duration: float = 0.5
@export var soal_url: String = ""                  # URL file JSON di Supabase
@export var MATCH_SCORE: float = 25

@onready var batu_container := $BatuContainer
@onready var general_level := $General

var pasangan_data: Array = []   # daftar pasangan kata baku–tidak baku
var spawn_index := 0            # index pasangan yang sedang dimainkan

func _ready():
	general_level._show_loading("Loading")
	fetch_soal()

# ======================
# Fetch soal dari Supabase
# ======================
func fetch_soal():
	var http_request = HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)
	var err = http_request.request(soal_url)
	if err != OK:
		print("Gagal request soal:", err)

func _on_request_completed(result, response_code, headers, body):
	if response_code == 200:
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		if typeof(json_data) == TYPE_ARRAY:
			for i in range(0, json_data.size(), 2):
				if i + 1 < json_data.size():
					var pair = [json_data[i], json_data[i + 1]]
					pasangan_data.append(pair)

			# acak urutan awal
			pasangan_data.shuffle()
			general_level._hide_loading()
			spawn_batu_awal()
		else:
			print("Format JSON tidak sesuai")
	else:
		print("HTTP Error:", response_code)

# ======================
# Spawn awal
# ======================
func spawn_batu_awal():
	spawn_index = 0
	_spawn_dari_pasangan(spawn_index, false)

# ======================
# Fungsi spawn dari pasangan
# ======================
func _spawn_dari_pasangan(pair_index: int, dari_luar: bool):
	if pasangan_data.is_empty():
		return

	# kalau sudah sampai akhir, reset index dan acak ulang
	if pair_index >= pasangan_data.size():
		pasangan_data.shuffle()
		spawn_index = 0
		pair_index = 0

	var pair = pasangan_data[pair_index]
	pair.shuffle()

	for i in range(2):
		var batu = batu_scene.instantiate()
		batu.set_data(pair[i]["text"], pair[i]["is_baku"])
		batu.connect("pressed", Callable(self, "_batu_dipilih").bind(batu))
		batu_container.add_child(batu)

		if dari_luar:
			batu.position = spawn_out_positions[i]
			var tween = create_tween()
			tween.tween_property(batu, "position", spawn_positions[i], move_duration)
		else:
			batu.position = spawn_positions[i]

# ======================
# Saat batu diklik
# ======================
func _batu_dipilih(batu):
	if batu.is_baku:
		general_level.add_score(MATCH_SCORE)
			 	
	for child in batu_container.get_children():
		var tween = create_tween()
		tween.tween_property(child, "position:x", child.position.x - 500, move_duration)
		tween.tween_callback(Callable(child, "queue_free"))

	await get_tree().create_timer(move_duration).timeout
	spawn_batu_baru()

# ======================
# Spawn set batu berikutnya
# ======================
func spawn_batu_baru():
	spawn_index += 1
	_spawn_dari_pasangan(spawn_index, true)
