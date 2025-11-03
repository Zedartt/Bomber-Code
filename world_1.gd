extends Node


func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Select_world.tscn")

func _on_level_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Level_1.tscn")
