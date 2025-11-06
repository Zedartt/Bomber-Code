extends Node


func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://information2.tscn")

func _on_info_button_pressed() -> void:
	SceneManager.go_back()
