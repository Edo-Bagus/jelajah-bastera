extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_hutan_kata_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/hutan_dan_gua_kata.tscn")


func _on_desa_eja_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/desa_eja.tscn")

func _on_sungai_baku_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/sungai_baku.tscn")

func _on_gunung_ragabasa_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/gunung_ragabasa.tscn")

func _on_kerajaan_bastera_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/kerajaan_bastera.tscn")
