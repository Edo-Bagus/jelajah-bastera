extends Node2D

@onready var main = get_parent()
@onready var rope_line: Line2D = $Line2D

func _ready():
	# Set width for visibility
	rope_line.width = 16
	
	# Load texture and check if it's loaded successfully
	var tex = preload("res://assets/Buttons/rope.png")
	if tex:
		rope_line.texture = tex
		print("Texture loaded successfully!")
	else:
		print("Error: Texture not found at path 'res://assets/Buttons/rope.png'")
		
	# Ensure texture mode is set to "repeat"
	rope_line.texture_mode = Line2D.LINE_TEXTURE_TILE
	rope_line.z_index = 20

	# Initially invisible
	rope_line.visible = false

func _process(_delta):
	if rope_line and is_instance_valid(rope_line):
		if main.dragging:
			# Check if points are valid and different
			if main.drag_start != main.drag_end:
				rope_line.points = [main.drag_start, main.drag_end]
				rope_line.visible = true
			else:
				# If points are the same, hide the line
				rope_line.visible = false
		else:
			rope_line.visible = false
