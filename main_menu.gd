extends Control
@onready var select_code_language = preload("res://Select_world.tscn")

func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(select_code_language)


func _on_exit_pressed() -> void:
	get_tree().quit()
