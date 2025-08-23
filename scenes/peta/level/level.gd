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

func _update_stars(val: float):
	print("test")
	var thresholds = [33, 66, 100]
	for i in range(3):
		if val >= thresholds[i]:
			if stars[i].texture != star_on:
				stars[i].texture = star_on
		else:
			stars[i].texture = star_off
