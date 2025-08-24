extends Node

# =========================
# Konfigurasi Game
# =========================
const PAIRS_PER_ROUND := 4

@export var MATCH_SCORE: float = 25
@export var mode: String = "synonym" # "synonym" atau "antonym"
@export var data_url: String = "https://kcrglneppkjtdoatdvzr.supabase.co/storage/v1/object/public/BankSoal/sinonim_antonim.json"
@export var background_gua: Texture
# =========================
# Referensi Node
# =========================
@onready var general_level := $General
@onready var timer: Control = $General/Timer
@onready var grid_container := $GridContainer
@onready var background := $Background
@onready var change_round := $ChangeRound
@onready var click_sound: AudioStreamPlayer = $ClickSound
@onready var wrong_sound: AudioStreamPlayer = $WrongSound
@onready var label := $Label

@export var timer_duration: float

# =========================
# State Game
# =========================
var is_checking := false
var opened_cards: Array = []

var synonym_pairs: Array = []
var antonym_pairs: Array = []

# =========================
# Lifecycle
# =========================
func _ready():
	Global.play_music(preload("res://assets/Sound/Hutan Kata.mp3"))
	Global.music_player.stream.loop = true
	general_level._show_loading("Loading")
	general_level.level = 1
	timer.disconnect("timer_finished", Callable(general_level, "_game_won"))
	timer.connect("timer_finished", Callable(self, "_change_round"))
	_fetch_data(data_url)

# =========================
# Data Loading
# =========================
func _fetch_data(url: String) -> void:
	var http := HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request(url)

func _on_request_completed(_result, response_code, _headers, body):
	if response_code != 200:
		push_error("Gagal load soal dari Supabase")
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Format JSON tidak sesuai")
		return

	synonym_pairs = data.get("synonyms", [])
	antonym_pairs = data.get("antonyms", [])

	general_level._hide_loading()
	_init_round()

# =========================
# Game Setup
# =========================
func _init_round():
	var pairs := (synonym_pairs if mode == "synonym" else antonym_pairs).duplicate()
	pairs.shuffle()

	if pairs.size() > PAIRS_PER_ROUND:
		pairs = pairs.slice(0, PAIRS_PER_ROUND)

	var words: Array = []
	for pair in pairs:
		words.append(pair[0])
		words.append(pair[1])

	words.shuffle()
	_populate_board(words)

	# 🔹 Buka semua kartu dulu
	for card in grid_container.get_children():
		card.flip(true)

	# 🔹 Tunggu 5 detik, lalu tutup semua
	await get_tree().create_timer(5.0).timeout
	for card in grid_container.get_children():
		if not card.is_matched:
			card.flip(false)

func _populate_board(words: Array) -> void:
	
	opened_cards.clear()
	# Bersihkan board lama
	for child in grid_container.get_children():
		child.queue_free()

	# Tambahkan kartu baru
	for word in words:
		var card = preload("res://scenes/hutan kata/Card/card.tscn").instantiate()
		card.word = word
		card.pressed.connect(_on_card_pressed.bind(card))
		grid_container.add_child(card)

# =========================
# Gameplay Logic
# =========================
func _on_card_pressed(card):
	if is_checking or card.is_flipped or card.is_matched:
		return

	card.flip()
	opened_cards.append(card)

	if opened_cards.size() == 2:
		is_checking = true
		_check_match()

func _check_match():
	var card1: TextureButton = opened_cards[0]
	var card2: TextureButton = opened_cards[1]
	
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(card1) and is_instance_valid(card2):
		if _is_pair(card1.word, card2.word):
			card1.mark_matched()
			card2.mark_matched()
			general_level.add_score(MATCH_SCORE)
			click_sound.play()

			if _all_cards_matched():
				await get_tree().create_timer(1.0).timeout
				_next_round()
		else:
			wrong_sound.play()
			card1.flip()
			card2.flip()



	opened_cards.clear()
	is_checking = false

func _is_pair(word_a: String, word_b: String) -> bool:
	var pairs := (synonym_pairs if mode == "synonym" else antonym_pairs)

	for pair in pairs:
		if (word_a == pair[0] and word_b == pair[1]) or (word_a == pair[1] and word_b == pair[0]):
			return true
	return false

func _all_cards_matched() -> bool:
	for card in grid_container.get_children():
		if not card.is_matched:
			return false
	return true

# =========================
# Ronde & Kemenangan
# =========================
func _next_round():
	is_checking = false
	_init_round()   # langsung lanjut generate ronde baru tanpa batas
	
func _change_round():
	change_round.show_result(general_level.progress_bar.value, 100)
	mode = "antonym"
	label.text = "Cari pasangan kata antonim di balik setiap kartu!"
	background.texture = background_gua
	_init_round()
	general_level.reset_timer()
	general_level.start_timer(timer_duration)
	timer.disconnect("timer_finished", Callable(self, "_change_round"))
	timer.connect("timer_finished", Callable(general_level, "_game_won"))
