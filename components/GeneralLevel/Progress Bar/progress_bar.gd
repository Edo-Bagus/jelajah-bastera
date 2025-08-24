extends Control

@export_range(0, 100) var value: float = 0 : set = set_value
@export var star_on: Texture2D
@export var star_off: Texture2D
@export var elephant_texture: Texture2D   # <-- ini yang diekspos

@onready var bar: TextureProgressBar = $Bar
@onready var elephant: Sprite2D = $ElephantHead
@onready var stars: Array[TextureRect] = [$Stars/Star1, $Stars/Star2, $Stars/Star3]
@onready var tween: Tween = create_tween()

func _ready():
	bar.min_value = 0
	bar.max_value = 100
	bar.value = value

	if elephant_texture != null:
		elephant.texture = elephant_texture

	_update_elephant(bar.value)
	_update_stars(bar.value)

func set_value(v: float):
	v = clamp(v, bar.min_value, bar.max_value)

	if tween != null:
		tween.kill()
	tween = create_tween()
	tween.tween_property(bar, "value", v, 0.5)
	tween.tween_callback(Callable(self, "_update_elephant")).set_delay(0.0)
	tween.tween_callback(Callable(self, "_update_stars")).set_delay(0.0)

	value = v

# =============================
# Tambahan: fungsi add_score
# =============================
func add_score(amount: float):
	set_value(value + amount)

func _update_elephant(val: float = bar.value):
	var t = float(val) / float(bar.max_value)
	var start_x = bar.global_position.x + 25
	var end_x = bar.global_position.x + bar.size.x - 25
	elephant.global_position = Vector2(lerp(start_x, end_x, t), elephant.global_position.y)

# Hitung jumlah bintang berdasarkan skor
func _get_star_count(val: float, max_score: float) -> int:
	var percent = val / max_score
	return int(clamp(round(percent * 3), 0, 3))


func _update_stars(val: float = bar.value):
	var star_count = _get_star_count(val, bar.max_value)
	for i in range(3):
		if i < star_count:
			if stars[i].texture != star_on:
				stars[i].texture = star_on
				_play_star_animation(stars[i])
		else:
			stars[i].texture = star_off

func _play_star_animation(star: TextureRect):
	var twn := create_tween()
	star.scale = Vector2(0.8, 0.8)
	
	var step1 = twn.tween_property(star, "scale", Vector2(1.2, 1.2), 0.15)
	step1.set_trans(Tween.TRANS_BACK)
	step1.set_ease(Tween.EASE_OUT)

	var step2 = twn.tween_property(star, "scale", Vector2(1, 1), 0.15)
	step2.set_trans(Tween.TRANS_BACK)
	step2.set_ease(Tween.EASE_IN_OUT)
