extends Node

@onready var go_world_1 = preload("res://world_1.tscn")
@onready var go_world_2 = preload("res://world_2.tscn")
@onready var go_back = preload("res://MainMenu.tscn")

func _on_world_1_pressed() -> void:
	get_tree().change_scene_to_packed(go_world_1)

func _on_world_2_pressed() -> void:
	get_tree().change_scene_to_packed(go_world_2)

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://MainMenu.tscn")
