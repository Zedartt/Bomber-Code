extends Node

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file("res://information3.tscn")


func _on_info_button_pressed() -> void:
	SceneManager.go_back()


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://information1.tscn")
