extends Node

@onready var tilemap := $TileMap
@onready var player := $CharacterBody2D

## Références aux Labels de l'interface
@onready var command_list : ItemList = $TextureRect/ItemList

const GRID_WIDTH := 7
const GRID_HEIGHT := 5
const CELL_SIZE := 64
const MAX_SCRIPT_LINES := 5

var tilemap_offset := Vector2.ZERO
var current_position := Vector2.ZERO
var tile_size := CELL_SIZE

# Le script que le joueur construit
var player_script := []

func _ready():
	tilemap_offset = tilemap.position
	_place_player()
	_place_door()
	#update_script_display()  # Affiche les lignes vides au démarrage

func _place_player():
	var grid_pos = Vector2(
		(GRID_WIDTH - 1) * CELL_SIZE + CELL_SIZE / 2.0,
		(GRID_HEIGHT - 1) * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.position = grid_pos + tilemap_offset
	current_position = player.position

func _place_door():
	var door = Sprite2D.new()
	door.texture = load("res://images/door.png")
	
	var grid_pos = Vector2(
		(GRID_WIDTH - 1) * CELL_SIZE + CELL_SIZE / 2.0,
		CELL_SIZE / 2.0
	)
	door.position = grid_pos + tilemap_offset
	
	if door.texture:
		var texture_size = door.texture.get_size()
		var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
		door.scale = Vector2(scale_factor, scale_factor)
	
	add_child(door)



# ========================================
# SYSTÈME D'AJOUT DE COMMANDES
# ========================================

func add_command_to_script(command: String):
	if player_script.size() >= MAX_SCRIPT_LINES:
		print("⚠️ Script plein ! Maximum 5 lignes")
		return false
	
	player_script.append(command)
	print("✅ Commande ajoutée : ", command)
	#update_script_display()  # 👈 Met à jour l'affichage !
	return true

func remove_command_at_index(index: int):
	if index >= 0 and index < player_script.size():
		player_script.remove_at(index)
		#update_script_display()  # 👈 Met à jour l'affichage !


# ========================================
# BOUTONS DE COMMANDE
# ========================================

func _on_btn_up_pressed():
	add_command_to_script("monter()")
	if command_list.item_count <=4 : 
		command_list.add_item("monter()")

func _on_btn_down_pressed():
	add_command_to_script("descendre()")
	if command_list.item_count <=4 : 
		command_list.add_item("descendre()")

func _on_btn_left_pressed():
	add_command_to_script("gauche()")
	if command_list.item_count <=4 : 
		command_list.add_item("gauche()")

func _on_btn_right_pressed():
	add_command_to_script("droite()")
	if command_list.item_count <=4 : 
		command_list.add_item("droite()")

# ========================================
# EXÉCUTION DU SCRIPT
# ========================================

func _on_start_pressed():
	print("▶️ EXÉCUTION DU SCRIPT")
	await execute_script()
	check_victory()

func execute_script():
	for i in range(player_script.size()):
		var cmd = player_script[i]
		print("Exécution ligne ", i + 1, " : ", cmd)
		await execute_command(cmd)

func execute_command(cmd: String):
	cmd = cmd.strip_edges()
	
	if cmd == "monter()":
		await move_up_animated()
	elif cmd == "descendre()":
		await move_down_animated()
	elif cmd == "gauche()":
		await move_left_animated()
	elif cmd == "droite()":
		await move_right_animated()
	else:
		print("❌ Commande inconnue : ", cmd)

# ========================================
# MOUVEMENTS ANIMÉS
# ========================================

func move_up_animated():
	var target = current_position + Vector2(0, -CELL_SIZE)
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

func move_down_animated():
	var target = current_position + Vector2(0, CELL_SIZE)
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

func move_left_animated():
	var target = current_position + Vector2(-CELL_SIZE, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

func move_right_animated():
	var target = current_position + Vector2(CELL_SIZE, 0)
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

# ========================================
# RESET
# ========================================

func clear_script():
	player_script.clear()
	print("🔄 Script réinitialisé")
	command_list.clear()


func _on_reset_pressed():
	print("🔄 RESET")
	clear_script()
	reset_player_position()
	
func _clear_list():
	command_list.clear()
	clear_script()
	

func reset_player_position():
	var grid_pos = Vector2(
		(GRID_WIDTH - 1) * CELL_SIZE + CELL_SIZE / 2.0,
		(GRID_HEIGHT - 1) * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.position = grid_pos + tilemap_offset
	current_position = player.position

# ========================================
# VICTOIRE
# ========================================

func check_victory():
	var door_pos = Vector2(
		(GRID_WIDTH - 1) * CELL_SIZE + CELL_SIZE / 2.0,
		CELL_SIZE / 2.0
	) + tilemap_offset
	
	var distance = player.position.distance_to(door_pos)
	
	if distance < CELL_SIZE / 2:
		print("🎉 VICTOIRE !")
		show_victory_screen()

func show_victory_screen():
	print("✨ Niveau terminé !")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://world_1.tscn")
