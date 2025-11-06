extends Node


func _on_info_button_pressed() -> void:
	SceneManager.go_back()
	
func _on_button_pressed() -> void:
		get_tree().change_scene_to_file("res://information8.tscn")


func _on_button_2_pressed() -> void:
	get_tree().change_scene_to_file("res://information6.tscn")
