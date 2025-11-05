extends Control
@onready var select_code_language = preload("res://Select_world.tscn")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

func _on_leave_buton_pressed() -> void:
	get_tree().quit()

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_packed(select_code_language)

func _process(delta):
	if Input.is_action_just_pressed("click"):
		audio_stream_player.play()
