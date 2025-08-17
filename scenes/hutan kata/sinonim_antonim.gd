extends Node

# =========================
# Konfigurasi Game
# =========================
const PAIRS_PER_ROUND := 2

@export var MATCH_SCORE: float = 25
@export var mode: String = "synonym" # "synonym" atau "antonym"
@export var max_rounds: int = 3
@export var data_url: String = "https://kcrglneppkjtdoatdvzr.supabase.co/storage/v1/object/public/BankSoal/sinonim_antonim.json"

# =========================
# Referensi Node
# =========================
@onready var loading_overlay := $Loading
@onready var grid_container := $GridContainer
@onready var progress_bar := $ProgressBar
@onready var win_label := $"Label"

# =========================
# State Game
# =========================
var current_round := 1
var is_checking := false
var opened_cards: Array = []

var synonym_pairs: Array = []
var antonym_pairs: Array = []

# =========================
# Lifecycle
# =========================
func _ready():
	_show_loading("Loading")
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

	_hide_loading()
	_init_round()

# =========================
# Game Setup
# =========================
func _init_round():
	print("=== Ronde %d ===" % current_round)

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

func _populate_board(words: Array) -> void:
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

	if _is_pair(card1.word, card2.word):
		await get_tree().create_timer(1.0).timeout
		card1.mark_matched()
		card2.mark_matched()
		progress_bar.set_value(progress_bar.value + MATCH_SCORE)

		if _all_cards_matched():
			await get_tree().create_timer(1.0).timeout
			_next_round()
	else:
		await get_tree().create_timer(1.0).timeout
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
	if current_round < max_rounds:
		current_round += 1
		_init_round()
	else:
		_game_won()

func _game_won():
	win_label.show()

# =========================
# Loading Overlay
# =========================
func _show_loading(text: String) -> void:
	loading_overlay.show_loading(text)

func _hide_loading() -> void:
	loading_overlay.hide_loading()
