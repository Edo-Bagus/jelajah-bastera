extends Control

@onready var loading_overlay := $Loading
@onready var progress_bar := $ProgressBar
@onready var popup := $PopupWin
@onready var timer_bar := $Timer

@export var timer_duration: float = 10

var level: int

func _ready():
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	start_timer(timer_duration)


func _game_won():
	var high_score = await Global.get_highscore(level)
	var current_score = progress_bar.value

	if current_score > high_score:
		high_score = current_score
		print(level, current_score)
		Global.save_highscore(level, current_score)

	popup.show_result(current_score, 100, high_score)
	

func add_score(score: float):
	progress_bar.add_score(score)
	
	
func set_score(score: float):
	progress_bar.set_value(score)

func start_timer(duration: float):
	timer_bar.start_timer(duration)
	
func reset_timer():
	timer_bar.reset_timer()
	
func _show_loading(text: String) -> void:
	loading_overlay.show_loading(text)

func _hide_loading() -> void:
	loading_overlay.hide_loading()
