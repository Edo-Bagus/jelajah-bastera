extends Control

@export_range(0, 100) var value: float = 100 : set = set_value
@export var clock_texture: Texture2D   
@export var duration: float = 10.0   # waktu total timer dalam detik

@onready var bar: TextureProgressBar = $Bar
@onready var clock: Sprite2D = $ClockIcon
@onready var tween: Tween = null

signal timer_finished   # <-- sinyal baru

func _ready():
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value

	if clock_texture != null:
		clock.texture = clock_texture

	_update_clock(bar.value)

	# mulai timer otomatis saat start
	start_timer()

func start_timer():
	if tween != null:
		tween.kill()
	tween = create_tween()
	# Tween dari 100 ke 0 dalam "duration"
	tween.tween_property(self, "value", 0, duration)
	# setelah tween selesai, panggil fungsi on_timer_finished
	tween.tween_callback(Callable(self, "_on_timer_finished"))
	
func reset_timer():
	if tween != null:
		tween.kill()  # stop animasi sebelumnya

	value = bar.max_value   # balikin ke nilai penuh (100)
	bar.value = value
	_update_clock(value)


func set_value(v: float):
	v = clamp(v, bar.min_value, bar.max_value)
	bar.value = v
	_update_clock(v)
	value = v

func _update_clock(val: float = bar.value):
	var t = float(val) / float(bar.max_value)
	var start_x = bar.global_position.x + 30
	var end_x = bar.global_position.x + bar.size.x
	clock.global_position = Vector2(lerp(start_x, end_x, t), clock.global_position.y)

func _on_timer_finished():
	emit_signal("timer_finished")
