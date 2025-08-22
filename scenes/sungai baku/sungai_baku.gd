extends Control

@export var batu_scene: PackedScene
@export var posisi_queue: Array[Vector2]          # 3 posisi target di layar: kiri, tengah, kanan
@export var spawn_out_position: Vector2           # posisi spawn dari kanan (off-screen)
@export var move_duration: float = 0.5
@export var soal_url: String = ""                 
@export var MATCH_SCORE: float = 25
@export var textures: Array[Texture2D] = []

@onready var batu_container := $BatuContainer
@onready var general_level := $General
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound

var pasangan_data: Array = []   # daftar pasangan kata baku–tidak baku
var queue: Array = []           # isi antrian (3 pasangan aktif)


# ======================
# Ready
# ======================
func _ready() -> void:
	general_level._show_loading("Loading")
	general_level.level = 2
	fetch_soal()


# ======================
# Fetch soal dari Supabase
# ======================
func fetch_soal() -> void:
	var http_request := HTTPRequest.new()
	add_child(http_request)
	http_request.request_completed.connect(_on_request_completed)

	var err := http_request.request(soal_url)
	if err != OK:
		print("Gagal request soal:", err)


func _on_request_completed(result: int, response_code: int, headers: PackedStringArray, body: PackedByteArray) -> void:
	if response_code == 200:
		var json_data = JSON.parse_string(body.get_string_from_utf8())
		if typeof(json_data) == TYPE_ARRAY:
			for i in range(0, json_data.size(), 2):
				if i + 1 < json_data.size():
					var pair = [json_data[i], json_data[i + 1]]
					pasangan_data.append(pair)
			pasangan_data.shuffle()

			general_level._hide_loading()
			init_queue()
		else:
			print("Format JSON tidak sesuai")
	else:
		print("HTTP Error:", response_code)


# ======================
# Init Queue (isi 3 pasangan awal, tanpa animasi)
# ======================
func init_queue() -> void:
	for i in range(3):
		var start_pos := posisi_queue[i]  # langsung ke posisi target, bukan spawn_out_position
		var hide_text := (i == 0) # pasangan pertama teks disembunyikan
		enqueue_new_pair(start_pos, posisi_queue[i], false, hide_text)


# ======================
# Spawn & masukkan pasangan baru ke queue
# ======================
func enqueue_new_pair(start_pos: Vector2, target_pos: Vector2, use_animation: bool = true, hide_text: bool = false) -> void:
	if pasangan_data.is_empty():
		return

	var pair = pasangan_data.pop_front() if pasangan_data.size() > 0 else null
	if pair == null:
		return

	pair.shuffle()
	var group: Array = []

	for j in range(2):
		var batu = batu_scene.instantiate()

		# kalau hide_text aktif → text dikosongkan
		if hide_text:
			batu.set_data("", pair[j]["is_baku"])
		else:
			batu.set_data(pair[j]["text"], pair[j]["is_baku"])

		# set texture random jika tersedia
		if textures.size() > 0:
			var random_tex := textures[randi() % textures.size()]
			batu.texture_normal = random_tex
			batu.texture_pressed = random_tex
			batu.texture_hover = random_tex
			
		if j == 1:
			start_pos.y += 100

		batu.position = start_pos
		batu_container.add_child(batu)

		# hanya index 2 (tengah) yang bisa diklik
		batu.connect("pressed", Callable(self, "_batu_dipilih").bind(batu, group))
		group.append(batu)
		
		if j == 1:
			target_pos.y += 100

		# jika pakai animasi → tween, kalau tidak → langsung set posisi target
		if use_animation:
			var tween := create_tween()
			tween.tween_property(batu, "position", target_pos, move_duration)
		else:
			batu.position = target_pos

	queue.append(group)



# ======================
# Saat batu diklik
# ======================
func _batu_dipilih(batu, group: Array) -> void:
	# hanya boleh klik group[1] (index 2 di queue)
	if queue.size() < 2 or group != queue[1]:
		return

	if batu.is_baku:
		general_level.add_score(MATCH_SCORE)
		click_sound.play()
	else:
		wrong_sound.play()

	shift_queue()


# ======================
# Geser queue
# ======================
func shift_queue() -> void:
	if queue.is_empty():
		return

	# hapus pasangan pertama (kiri)
	var first_group: Array = queue.pop_front()
	for b in first_group:
		var tween := create_tween()
		tween.tween_property(b, "position:x", b.position.x - 500, move_duration)
		tween.tween_callback(Callable(b, "queue_free"))

	# geser pasangan 2 → posisi 1, pasangan 3 → posisi 2
	for i in range(queue.size()):
		var target_pos := posisi_queue[i]
		for j in range(queue[i].size()):
			var tween := create_tween()
			if j == 1:
				target_pos.y += 100
			tween.tween_property(queue[i][j], "position", target_pos, move_duration)

	# tambahkan pasangan baru di index 3 (spawn dari kanan → geser ke kanan layar)
	await get_tree().create_timer(move_duration).timeout
	enqueue_new_pair(spawn_out_position, posisi_queue[2])
