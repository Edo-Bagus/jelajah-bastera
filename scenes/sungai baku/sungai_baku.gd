extends Control

@export var batu_scene: PackedScene
@export var spawn_positions: Array[Vector2]       # 2 posisi target di layar
@export var spawn_out_positions: Array[Vector2]   # 2 posisi awal (misal kiri dan kanan)
@export var move_duration: float = 0.5
@export var soal_url: String = ""                  # URL file JSON di Supabase
@export var max_spawn: int = 5                     # jumlah set batu yang dimainkan

@onready var batu_container = $BatuContainer
@onready var loading_overlay := $Loading
@onready var progress_bar := $ProgressBar

var pasangan_data: Array = []   # daftar pasangan kata baku–tidak baku
var spawn_count := 0            # hitung berapa set yang sudah muncul

func _ready():
	_show_loading("Loading")
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
			# buat pasangan dari data
			for i in range(0, json_data.size(), 2):
				if i + 1 < json_data.size():
					var pair = [json_data[i], json_data[i + 1]]
					pasangan_data.append(pair)
			# acak urutan pasangan
			pasangan_data.shuffle()
			_hide_loading()
			spawn_batu_awal()
		else:
			print("Format JSON tidak sesuai")
	else:
		print("HTTP Error:", response_code)

# ======================
# Spawn awal
# ======================
func spawn_batu_awal():
	spawn_count = 1
	_spawn_dari_pasangan(0, false)

# ======================
# Fungsi spawn dari pasangan
# ======================
func _spawn_dari_pasangan(pair_index: int, dari_luar: bool):
	if pair_index >= pasangan_data.size():
		_game_selesai()
		return

	var pair = pasangan_data[pair_index]
	pair.shuffle() # acak posisi baku/tidak baku di kiri/kanan

	for i in range(2):
		var batu = batu_scene.instantiate()
		batu.set_data(pair[i]["text"], pair[i]["is_baku"]) # pakai fungsi baru
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
	if not batu.is_baku:
		# Jawaban salah, kurangi progress bar
		progress_bar.value -= 1
		if progress_bar.value <= 0:
			return
			 	
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
	spawn_count += 1
	if spawn_count > max_spawn or spawn_count > pasangan_data.size():
		_game_selesai()
		return
	_spawn_dari_pasangan(spawn_count - 1, true)

# ======================
# Saat game selesai
# ======================
func _game_selesai():
	print("Game selesai! Soal terjawab:", spawn_count, "set.")
	# Bisa lanjut ke popup skor, scene lain, dll.
	
# =========================
# Loading Overlay
# =========================
func _show_loading(text: String) -> void:
	loading_overlay.show_loading(text)

func _hide_loading() -> void:
	loading_overlay.hide_loading()
