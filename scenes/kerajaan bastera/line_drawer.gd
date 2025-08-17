extends Node2D
@onready var main = get_parent()

func _draw():
	if main.dragging:
		draw_line(main.drag_start - global_position, main.drag_end - global_position, Color.BLACK, 4)
