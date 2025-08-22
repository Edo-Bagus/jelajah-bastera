extends Control

@onready var scorebars = {
	"Antonim": {
		"bar": $Panel/ScorebarAntonim,
		"icon": $Panel/IconAntonim
	},
	"Baku": {
		"bar": $Panel/ScorebarBaku,
		"icon": $Panel/IconBaku
	},
	"Kapital": {
		"bar": $Panel/ScorebarKapital,
		"icon": $Panel/IconKapital
	},
	"Asing": {
		"bar": $Panel/ScorebarAsing,
		"icon": $Panel/IconAsing
	},
	"Imbuhan": {
		"bar": $Panel/ScorebarImbuhan,
		"icon": $Panel/IconImbuhan
	}
}

@export var extra_offset_left: float = 40   # offset di posisi min
@export var extra_offset_right: float = -40   # offset di posisi max
@export var extra_offset_y: float = -20.0      # offset vertikal

var scores = []

func _ready():
	await load_scores()
	# Hubungkan event semua scorebar ke handler
	for key in scorebars.keys():
		var bar = scorebars[key]["bar"]
		bar.connect("value_changed", Callable(self, "_on_scorebar_changed").bind(key))
		# update posisi awal
		_on_scorebar_changed(bar.value, key)
		
	$Panel/ScorebarAntonim.value = scores[0]
	$Panel/ScorebarBaku.value = scores[1]
	$Panel/ScorebarKapital.value = scores[2]
	$Panel/ScorebarAsing.value = scores[4]
	$Panel/ScorebarImbuhan.value = scores[3]
	
	$Panel/SkorSinonim.text = str(int(scores[0]))
	$Panel/SkorImbuhan.text = str(int(scores[3]))
	$Panel/SkorKapital.text = str(int(scores[2]))
	$Panel/SkorBaku.text = str(int(scores[1]))
	$Panel/SkorIstilah.text = str(int(scores[4]))
	
func load_scores() -> void:
	for i in range(0, 5):
		var score = await Global.get_highscore(i + 1)
		scores.append(score)

func _on_scorebar_changed(value: float, key: String):
	var bar = scorebars[key]["bar"]
	var icon = scorebars[key]["icon"]

	var bar_min = bar.get_min()
	var bar_max = bar.get_max()
	var ratio = (value - bar_min) / float(bar_max - bar_min)

	var bar_width = bar.size.x

	# interpolasi offset X sesuai ratio
	var offset_x = lerp(extra_offset_left, extra_offset_right, ratio)

	# posisi icon mengikuti bar + offset
	icon.position.x = bar.position.x + ratio * bar_width - (icon.size.x / 2) + offset_x
	icon.position.y = bar.position.y + extra_offset_y


func _on_texture_button_pressed() -> void:
	hide()
