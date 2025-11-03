extends Node

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Select_world.tscn")

func go_to_level() -> void :
	get_tree().change_scene_to_file("res://Level_1.tscn")
