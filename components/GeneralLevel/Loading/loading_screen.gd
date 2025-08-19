extends Control

signal loading_finished

@export var fade_duration: float = 0.5
@export var loading_text: String = "Memuat..."

@onready var bg = $ColorRect
@onready var label = $Label

func _ready():
	label.text = loading_text
	modulate.a = 0
	visible = false

func show_loading(text_override: String = ""):
	if text_override != "":
		label.text = text_override
	else:
		label.text = loading_text

	visible = true
	_create_fade(self, 1.0)
	start_text_animation()

func hide_loading():
	var tween = _create_fade(self, 0.0)
	tween.tween_callback(Callable(self, "_on_fade_out_complete"))

func _on_fade_out_complete():
	visible = false
	stop_text_animation()
	emit_signal("loading_finished")

func start_text_animation():
	var tween = create_tween().set_loops()
	tween.tween_property(label, "modulate:a", 0.3, 0.5)
	tween.tween_property(label, "modulate:a", 1.0, 0.5)
	tween.play()

func stop_text_animation():
	label.modulate.a = 1.0

func _create_fade(node: CanvasItem, target_alpha: float) -> Tween:
	var tween = create_tween()
	tween.tween_property(node, "modulate:a", target_alpha, fade_duration)
	return tween
