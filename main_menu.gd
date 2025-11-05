extends Control
@onready var select_code_language = preload("res://Select_world.tscn")

func _on_leave_buton_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(select_code_language)


func _on_texture_button_pressed() -> void:
	get_tree().change_scene_to_file("res://shop.tscn")
