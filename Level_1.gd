extends Node

@onready var tilemap := $TileMap
@onready var player := $CharacterBody2D
@onready var command_list : ItemList = $TextureRect/ItemList

const GRID_WIDTH := 7
const GRID_HEIGHT := 7
const CELL_SIZE := 64
const MAX_SCRIPT_LINES := 5

# Limites du terrain jouable
const MIN_COL := 0
const MAX_COL := 6
const MIN_ROW := -1
const MAX_ROW := 5

var tilemap_offset := Vector2.ZERO
var current_position := Vector2.ZERO
var tile_size := CELL_SIZE

# Position en grille
var grid_x := 6
var grid_y := 5

# Le script que le joueur construit
var player_script := []

func _ready():
	tilemap_offset = tilemap.position
	_place_player()
	_place_door()

func _place_player():
	grid_x = 6
	grid_y = 5
	
	var grid_pos = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.position = grid_pos + tilemap_offset
	current_position = player.position
	print("🎮 Joueur placé à la case (6, 5)")

func _place_door():
	var door = Sprite2D.new()
	door.texture = load("res://images/door.png")
	
	var grid_pos = Vector2(
		6 * CELL_SIZE + CELL_SIZE / 2.0,
		-1 * CELL_SIZE + CELL_SIZE / 2.0
	)
	door.position = grid_pos + tilemap_offset
	
	if door.texture:
		var texture_size = door.texture.get_size()
		var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
		door.scale = Vector2(scale_factor, scale_factor)
	
	add_child(door)
	print("🚪 Porte placée à la case (6, -1)")

# ========================================
# SYSTÈME D'AJOUT DE COMMANDES
# ========================================

func add_command_to_script(command: String):
	if player_script.size() >= MAX_SCRIPT_LINES:
		print("⚠️ Script plein ! Maximum 5 lignes")
		return false
	
	player_script.append(command)
	print("✅ Commande ajoutée : ", command)
	return true

func remove_command_at_index(index: int):
	if index >= 0 and index < player_script.size():
		player_script.remove_at(index)

# ========================================
# BOUTONS DE COMMANDE
# ========================================

func _on_btn_up_pressed():
	add_command_to_script("monter()")
	if command_list.item_count <= 4: 
		command_list.add_item("monter()")

func _on_btn_down_pressed():
	add_command_to_script("descendre()")
	if command_list.item_count <= 4: 
		command_list.add_item("descendre()")

func _on_btn_left_pressed():
	add_command_to_script("gauche()")
	if command_list.item_count <= 4: 
		command_list.add_item("gauche()")

func _on_btn_right_pressed():
	add_command_to_script("droite()")
	if command_list.item_count <= 4: 
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
# MOUVEMENTS ANIMÉS AVEC LIMITES
# ========================================

func move_up_animated():
	var new_y = grid_y - 1
	
	if new_y < MIN_ROW:
		print("❌ Impossible de monter : mur !")
		return
	
	grid_y = new_y
	var target = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	) + tilemap_offset
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

func move_down_animated():
	var new_y = grid_y + 1
	
	if new_y > MAX_ROW:
		print("❌ Impossible de descendre : mur !")
		return
	
	grid_y = new_y
	var target = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	) + tilemap_offset
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

func move_left_animated():
	var new_x = grid_x - 1
	
	if new_x < MIN_COL:
		print("❌ Impossible d'aller à gauche : mur !")
		return
	
	grid_x = new_x
	var target = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	) + tilemap_offset
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

func move_right_animated():
	var new_x = grid_x + 1
	
	if new_x > MAX_COL:
		print("❌ Impossible d'aller à droite : mur !")
		return
	
	grid_x = new_x
	var target = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	) + tilemap_offset
	
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

func reset_player_position():
	grid_x = 6
	grid_y = 5
	
	var grid_pos = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.position = grid_pos + tilemap_offset
	current_position = player.position

func _clear_list():
	command_list.clear()
	clear_script()
	

# ========================================
# VICTOIRE
# ========================================

func check_victory():
	# La porte est à la case (6, -1)
	if grid_x == 6 and grid_y == -1:
		print("🎉 VICTOIRE !")
		show_victory_screen()
	else:
		print("Position actuelle : (", grid_x, ", ", grid_y, ")")

func show_victory_screen():
	get_tree().change_scene_to_file("res://world_1.tscn")
	print("✨ Niveau terminé !")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://world_1.tscn")
