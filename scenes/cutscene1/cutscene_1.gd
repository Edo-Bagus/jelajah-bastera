extends Control # Atau Node2D, tergantung jenis node Cutscene1

@onready var texture_rect = $Cutscene1Bg
@onready var cutscene_audio = $Cutscene1Audio

func _ready():
	Global.stop_music()
	fade_in()

func fade_in():
	# Gunakan create_tween() untuk membuat dan mengelola tween
	var fade_tween = create_tween()
	
	# Atur alpha awal ke 0.0 (transparan) agar fade-in mulai dari transparan
	texture_rect.modulate.a = 0.0
	
	# Animasikan properti 'a' (alpha) dari modulasi ke 1.0 (penuh)
	fade_tween.tween_property(texture_rect, "modulate:a", 1.0, 1.0)
	
	# Tunggu tween selesai sebelum memutar audio
	await fade_tween.finished
	cutscene_audio.play()


func fade_out_and_next_scene():
	var fade_out_tween = create_tween()
	fade_out_tween.tween_property(texture_rect, "modulate", Color(0, 0, 0, 1), 1.0)
	await fade_out_tween.finished
	get_tree().change_scene_to_file("res://scenes/peta/peta.tscn")

func _on_skip_button_pressed():
	# Hentikan audio jika sedang diputar
	cutscene_audio.stop()
	# Lanjutkan ke transisi akhir
	fade_out_and_next_scene()


func _on_cutscene_1_audio_finished() -> void:
	fade_out_and_next_scene()
