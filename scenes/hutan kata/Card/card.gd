extends TextureButton

## --- Constants ---
const MATCHED_FADE: Color = Color(1, 1, 1, 0.5)

## --- Exported Properties ---
@export var word: String = ""
@export var card_closed: Texture
@export var card_open: Texture

## --- Internal State ---
var is_flipped: bool = false
var is_matched: bool = false
var tween: Tween

## --- Node References ---
@onready var label_front: Label = $"Front Label"

func _ready() -> void:
	reset_scale()
	label_front.text = word
	_adjust_font_size()
	_update_display()

func _adjust_font_size():
	if label_front:
		var base_size = 40
		var min_size = 8
		var size = base_size - (word.length() * 1.5)
		size = clamp(size, min_size, base_size)

		if label_front.label_settings:
			# clone biar nggak shared ke semua
			label_front.label_settings = label_front.label_settings.duplicate()
			label_front.label_settings.font_size = size
		else:
			label_front.add_theme_font_size_override("font_size", size)


## --- Public Methods ---
func flip() -> void:
	if is_matched:
		return
	is_flipped = not is_flipped
	_animate_flip()

func mark_matched() -> void:
	is_matched = true
	disabled = true
	modulate = MATCHED_FADE
	_update_display()

func reset_card() -> void:
	is_flipped = false
	is_matched = false
	disabled = false
	modulate = Color.WHITE
	reset_scale()
	_update_display()

## --- Private Helpers ---
func _update_display() -> void:
	if is_flipped or is_matched:
		texture_normal = card_open
		label_front.text = word
	else:
		texture_normal = card_closed
		label_front.text = ""

func _animate_flip() -> void:
	if tween and tween.is_running():
		return

	tween = create_tween()
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_ease(Tween.EASE_IN_OUT)

	# Mengecil di sumbu X
	tween.tween_property(self, "scale:x", 0.0, 0.15).set_ease(Tween.EASE_IN)

	# Ganti tampilan saat skala 0
	tween.tween_callback(Callable(self, "_update_display"))

	# Membesar kembali ke skala normal
	tween.tween_property(self, "scale:x", 1.0, 0.15).set_ease(Tween.EASE_OUT)

func reset_scale() -> void:
	scale = Vector2.ONE
