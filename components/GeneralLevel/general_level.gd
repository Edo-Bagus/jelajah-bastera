extends Control

@onready var loading_overlay := $Loading
@onready var progress_bar := $ProgressBar
@onready var popup := $PopupWin
@onready var timer_bar := $Timer

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE

func _game_won():
	popup.show_result(progress_bar.value, 100)

func add_score(score: float):
	progress_bar.add_score(score)
	
func set_score(score: float):
	progress_bar.set_value(score)

func start_timer():
	timer_bar.start_timer()
	
func reset_timer():
	timer_bar.reset_timer()
	
func _show_loading(text: String) -> void:
	loading_overlay.show_loading(text)

func _hide_loading() -> void:
	loading_overlay.hide_loading()
