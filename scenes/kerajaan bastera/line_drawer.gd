extends Node2D

@onready var main = get_parent()
@onready var rope_line: Line2D = $Line2D

@export var rope_texture: Texture2D

func _ready():
	# Atur modulate parent (LineDrawer) ke putih.
	#self.modulate = Color.WHITE
	
	if rope_texture:
		rope_line.texture = rope_texture
		rope_line.texture_mode = Line2D.LINE_TEXTURE_TILE
		rope_line.width = 16
		rope_line.z_index = 20
		# Atur modulate anak (Line2D) ke putih juga, untuk jaga-jaga.
		#rope_line.modulate = Color.WHITE
		print("Tekstur tali berhasil dimuat dan diatur!")
	else:
		print("Peringatan: Tekstur tali belum diatur di Editor!")
	
	rope_line.visible = false

func _process(_delta):
	if is_instance_valid(rope_line) and main:
		if main.dragging:
			if main.drag_start != main.drag_end:
				rope_line.points = [main.drag_start, main.drag_end]
				rope_line.visible = true
			else:
				rope_line.visible = false
		else:
			rope_line.visible = false
