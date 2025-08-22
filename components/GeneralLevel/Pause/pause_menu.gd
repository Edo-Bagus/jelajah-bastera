extends Control

signal resume_pressed
signal back_pressed

@onready var volume_slider: HSlider = $Panel/VolumeSlider
@onready var mute_button: TextureButton = $Panel/MuteButton

var is_muted: bool = false
var last_volume: float = 0.5  # default jika belum ada config

const CONFIG_PATH := "user://settings.cfg"
# pastikan file ini ada dan benar; nama konstan jelas:
const TEX_MUTED := preload("res://assets/Buttons/Button mute.png")    # ikon ketika *muted*
const TEX_UNMUTED := preload("res://assets/Buttons/Button music mute.png")# ikon ketika *unmuted*

func _ready():
	visible = false
	$Panel/HBoxContainer/Resume.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/HBoxContainer/Home.process_mode = Node.PROCESS_MODE_ALWAYS
	$Panel/HBoxContainer/Retry.process_mode = Node.PROCESS_MODE_ALWAYS
	volume_slider.process_mode = Node.PROCESS_MODE_ALWAYS
	mute_button.process_mode = Node.PROCESS_MODE_ALWAYS

	# === Load config ===
	_load_settings()

	# setup slider
	volume_slider.min_value = 0
	volume_slider.max_value = 1
	volume_slider.step = 0.01
	volume_slider.value = last_volume
	volume_slider.connect("value_changed", Callable(self, "_on_volume_changed"))

	# setup mute button
	mute_button.connect("pressed", Callable(self, "_on_mute_pressed"))

	# set volume awal + tampilan ikon + enable/disable slider
	if is_muted:
		_set_master_volume(0)
		volume_slider.value = 0
		# non-aktifkan input mouse ke slider saat mute
		volume_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		# tampilkan ikon *muted*
		mute_button.texture_normal = TEX_MUTED
	else:
		_set_master_volume(last_volume)
		# slider boleh diinteraksi
		volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP
		# tampilkan ikon *unmuted*
		mute_button.texture_normal = TEX_UNMUTED


func show_menu():
	get_tree().paused = true
	visible = true

func hide_menu():
	get_tree().paused = false
	visible = false

func _on_ResumeButton_pressed():
	hide_menu()
	emit_signal("resume_pressed")

func _on_BackToMapButton_pressed():
	get_tree().paused = false
	Global.play_music(preload("res://assets/Sound/Main Menu.mp3"))
	Global.music_player.stream.loop = true
	get_tree().change_scene_to_file("res://scenes/peta/peta.tscn")
	emit_signal("back_pressed")
	
func _on_Retry_pressed():
	get_tree().paused = false
	get_tree().reload_current_scene()


# === Tambahan untuk Volume & Mute ===

func _on_volume_changed(value: float):
	if not is_muted:
		_set_master_volume(value)
		last_volume = value
		_save_settings()

func _on_mute_pressed():
	is_muted = !is_muted
	if is_muted:
		_set_master_volume(0)
		volume_slider.value = 0   # otomatis geser ke kiri
		volume_slider.mouse_filter = Control.MOUSE_FILTER_IGNORE
		mute_button.texture_normal = TEX_MUTED
	else:
		_set_master_volume(last_volume)
		volume_slider.value = last_volume
		volume_slider.mouse_filter = Control.MOUSE_FILTER_STOP
		mute_button.texture_normal = TEX_UNMUTED
	_save_settings()

func _set_master_volume(value: float):
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_volume_db(bus_idx, linear_to_db(value))


# === Config Save/Load ===

func _save_settings():
	var config = ConfigFile.new()
	config.set_value("audio", "volume", last_volume)
	config.set_value("audio", "muted", is_muted)
	config.save(CONFIG_PATH)

func _load_settings():
	var config = ConfigFile.new()
	var err = config.load(CONFIG_PATH)
	if err == OK:
		last_volume = config.get_value("audio", "volume", 0.5)
		is_muted = config.get_value("audio", "muted", false)
