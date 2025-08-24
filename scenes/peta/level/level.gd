extends TextureButton

@export var star_on: Texture2D
@export var star_off: Texture2D
@export var texture_on: Texture
@export var texture_off: Texture

@onready var stars: Array[TextureRect] = [$Stars/Star1, $Stars/Star2, $Stars/Star3]

func _ready() -> void:
	if texture_on != null:
		texture_normal = texture_on
		texture_disabled = texture_off

func _get_star_count(val: float, max_score: float) -> int:
	var percent = val / max_score
	return int(clamp(round(percent * 3), 0, 3))


func _update_stars(val: float = 100):
	var star_count = _get_star_count(val, 100)
	for i in range(3):
		if i < star_count:
			if stars[i].texture != star_on:
				stars[i].texture = star_on
		else:
			stars[i].texture = star_off
