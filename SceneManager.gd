extends Node

# Fonction pour changer de scène tout en sauvegardant la précédente
func go_to_scene(scene_path: String) -> void:
	get_tree().set_meta("previous_scene", get_tree().current_scene.scene_file_path)
	get_tree().change_scene_to_file(scene_path)

# Fonction pour revenir à la scène précédente
func go_back() -> void:
	if get_tree().has_meta("previous_scene"):
		var previous_scene = get_tree().get_meta("previous_scene")
		get_tree().change_scene_to_file(previous_scene)
	else:
		print("⚠️ Pas de scène précédente enregistrée.")
