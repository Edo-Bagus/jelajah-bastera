extends Control

@onready var hutan_kata := $"Hutan Kata"
@onready var desa_eja := $"Desa Eja"
@onready var sungai_baku := $"Sungai Baku"
@onready var gunung_ragabasa := $"Gunung Ragabasa"
@onready var kerajaan_bastera := $"Kerajaan Bastera"

var scores = []


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	await load_scores()
	update_stars()
	#check_unlocks()
	
func update_stars() -> void:
	hutan_kata._update_stars(scores[0])
	sungai_baku._update_stars(scores[1])
	desa_eja._update_stars(scores[2])
	gunung_ragabasa._update_stars(scores[3])
	kerajaan_bastera._update_stars(scores[4])

# Load semua skor dulu
func load_scores() -> void:
	for i in range(0, 5):
		var score = await Global.get_highscore(i + 1)
		scores.append(score)
	return


# Baru cek kondisi setelah semua skor masuk
func check_unlocks() -> void:
	if scores[0] != -2:
		sungai_baku.disabled = false
	
	if scores[1] != -2:
		desa_eja.disabled = false
		
	if scores[2] != -2:
		gunung_ragabasa.disabled = false
		
	if scores[3] != -2:
		kerajaan_bastera.disabled = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_hutan_kata_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hutan kata/hutan_dan_gua_kata.tscn")


func _on_desa_eja_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/desa eja/desa_eja.tscn")

func _on_sungai_baku_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/sungai baku/sungai_baku.tscn")

func _on_gunung_ragabasa_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gunung ragabasa/gunung_ragabasa.tscn")

func _on_kerajaan_bastera_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/kerajaan bastera/kerajaan_bastera.tscn")


func _on_skor_pressed() -> void:
	$PopupFinalSkor.show()


func _on_refresh_pressed() -> void:
	await load_scores()
	update_stars()
