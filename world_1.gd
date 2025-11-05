extends Node

@onready var popup_panel1: PopupPanel = $PopupPanel1
@onready var popup_panel2: PopupPanel = $PopupPanel2
@onready var popup_panel3: PopupPanel = $PopupPanel3
@onready var popup_panel4: PopupPanel = $PopupPanel4
@onready var popup_panel5: PopupPanel = $PopupPanel5

func _ready():
	popup_panel1.hide()
	popup_panel2.hide()
	popup_panel3.hide()
	popup_panel4.hide()
	popup_panel5.hide()

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://Select_world.tscn")
	popup_panel1.hide()
	popup_panel2.hide()
	popup_panel3.hide()
	popup_panel4.hide()
	popup_panel5.hide()

func _on_level_1_pressed() -> void:	
	popup_panel1.popup_centered()

func _on_level_2_pressed() -> void:
	popup_panel2.popup_centered()

func _on_level_3_pressed() -> void:
	popup_panel3.popup_centered()

func _on_level_4_pressed() -> void:
	popup_panel4.popup_centered()

func _on_level_5_pressed() -> void:
	popup_panel5.popup_centered()

func _on_close_button_pressed() -> void:
	popup_panel1.hide()
	popup_panel2.hide()
	popup_panel3.hide()
	popup_panel4.hide()
	popup_panel5.hide()

func _on_play_button_1_pressed() -> void:
	get_tree().change_scene_to_file("res://Level_1.tscn")

func _on_play_button_2_pressed() -> void:
	pass # Replace with function body.

func _on_play_button_3_pressed() -> void:
	pass # Replace with function body.

func _on_play_button_4_pressed() -> void:
	pass # Replace with function body.

func _on_play_button_5_pressed() -> void:
	pass # Replace with function body.
