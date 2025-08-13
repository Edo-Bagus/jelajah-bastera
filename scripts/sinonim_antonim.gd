extends Node

@export var mode: String = "synonym" # "synonym" atau "antonym"
var opened_cards: Array = []
var score: int = 0

var synonym_pairs = []
var antonym_pairs = []

var supabase_url = "https://kcrglneppkjtdoatdvzr.supabase.co/storage/v1/object/public/BankSoal/sinonim_antonim.json"

func _ready():
	var http = HTTPRequest.new()
	add_child(http)
	http.request_completed.connect(_on_request_completed)
	http.request(supabase_url)

func _on_request_completed(result, response_code, headers, body):
	if response_code != 200:
		push_error("Gagal load soal dari Supabase")
		return

	var data = JSON.parse_string(body.get_string_from_utf8())
	if typeof(data) != TYPE_DICTIONARY:
		push_error("Format JSON tidak sesuai")
		return

	# Ambil data dari JSON
	synonym_pairs = data.get("synonyms", [])
	antonym_pairs = data.get("antonyms", [])

	_init_board()

func _init_board():
	var selected_pairs = []
	if mode == "synonym":
		selected_pairs = synonym_pairs.duplicate()
	else:
		selected_pairs = antonym_pairs.duplicate()

	# Acak urutan pasangan
	selected_pairs.shuffle()

	# Ambil hanya 4 pasang (total 8 kartu)
	if selected_pairs.size() > 4:
		selected_pairs = selected_pairs.slice(0, 4)

	var words = []
	for pair in selected_pairs:
		words.append(pair[0])
		words.append(pair[1])

	words.shuffle()

	# Bersihkan isi grid sebelum isi ulang
	var grid = $GridContainer

	for w in words:
		var card = preload("res://components/card.tscn").instantiate()
		card.word = w
		card.connect("pressed", Callable(self, "_on_card_pressed").bind(card))
		grid.add_child(card)
		
func _on_card_pressed(card):
	if card.is_flipped or card.is_matched:
		return
	
	card.flip()
	opened_cards.append(card)

	if opened_cards.size() == 2:
		_check_match()

func _check_match():
	var card1 = opened_cards[0]
	var card2 = opened_cards[1]

	if _is_pair(card1.word, card2.word):
		card1.mark_matched()
		card2.mark_matched()
		score += 1
	else:
		await get_tree().create_timer(1.0).timeout
		card1.hide_card()
		card2.hide_card()

	opened_cards.clear()

func _is_pair(word_a, word_b) -> bool:
	var pairs = synonym_pairs if mode == "synonym" else antonym_pairs
	for pair in pairs:
		if (word_a == pair[0] and word_b == pair[1]) or (word_a == pair[1] and word_b == pair[0]):
			return true
	return false
