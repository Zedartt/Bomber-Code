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
var player_script: Array[String] = []

# Mode while : le prochain clic sur une direction crée un bloc while_xxx
var while_mode: bool = false

func _ready():
	tilemap_offset = tilemap.position
	_place_player()
	_place_bombs()
	_place_weapon()
	_place_boss()

func _place_player():
	grid_x = 0
	grid_y = 3 # le joueur est à la case (0, 2)
	
	var grid_pos = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.position = grid_pos + tilemap_offset
	current_position = player.position
	print("🎮 Joueur placé à la case (0, 2)")
	
func _place_boss():
	var boss = Sprite2D.new()
	boss.texture = load("res://images/boss.png")
	
	var grid_x = 1
	var grid_y = 1    # la porte est à la case (6, 2)
	
	var grid_pos = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	boss.position = grid_pos + tilemap_offset
	
	if boss.texture:
		var texture_size = boss.texture.get_size()
		var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
		boss.scale = Vector2(scale_factor, scale_factor)
	
	add_child(boss)
	print("🚪 Porte placée à la case (6, 2)")

func _place_weapon():
	var weapon_positions = [
		Vector2(5 , 2)
	]
	
	for pos in weapon_positions:
		var weapon = Sprite2D.new()
		weapon.texture = load("res://images/weapon.png")
		
		var grid_pos = Vector2(
			pos.x * CELL_SIZE + CELL_SIZE / 2.0,
			pos.y * CELL_SIZE + CELL_SIZE / 2.0
		)
		weapon.position = grid_pos + tilemap_offset
		
		if weapon.texture:
			var texture_size = weapon.texture.get_size()
			var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
			weapon.scale = Vector2(scale_factor, scale_factor)
		
		add_child(weapon)
	
func _place_bombs():
	var bomb_positions = [
		Vector2(0, -1),
		Vector2(0, 0),
		Vector2(0, 1),
		Vector2(0, 2),
		Vector2(0, 4),
		Vector2(0, 5),
		Vector2(6, -1),
		Vector2(6, 0),
		Vector2(6, 1),
		Vector2(6, 2),
		Vector2(6, 3),
		Vector2(6, 4),
		Vector2(6, 5),
		
	]
	
	for pos in bomb_positions:
		var bomb = Sprite2D.new()
		bomb.texture = load("res://images/bomb_state1.png")
		
		# 💡 Décalage vertical pour aligner avec ta grille
		var grid_pos = Vector2(
			pos.x * CELL_SIZE + CELL_SIZE / 2.0,
			pos.y * CELL_SIZE + CELL_SIZE / 2.0
		)
		bomb.position = grid_pos + tilemap_offset
		
		if bomb.texture:
			var texture_size = bomb.texture.get_size()
			var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
			bomb.scale = Vector2(scale_factor, scale_factor)
		
		add_child(bomb)


# ========================================
# SYSTÈME D'AJOUT DE COMMANDES
# ========================================

func add_command_to_script(command: String) -> bool:
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
	if while_mode:
		if add_command_to_script("while_up"):
			if command_list.item_count <= 4:
				command_list.add_item("while pas de mur → haut")
		while_mode = false
	else:
		if add_command_to_script("monter()"):
			if command_list.item_count <= 4:
				command_list.add_item("monter()")

func _on_btn_down_pressed():
	if while_mode:
		if add_command_to_script("while_down"):
			if command_list.item_count <= 4:
				command_list.add_item("while pas de mur → bas")
		while_mode = false
	else:
		if add_command_to_script("descendre()"):
			if command_list.item_count <= 4:
				command_list.add_item("descendre()")

func _on_btn_left_pressed():
	if while_mode:
		if add_command_to_script("while_left"):
			if command_list.item_count <= 4:
				command_list.add_item("while pas de mur → gauche")
		while_mode = false
	else:
		if add_command_to_script("gauche()"):
			if command_list.item_count <= 4:
				command_list.add_item("gauche()")

func _on_btn_right_pressed():
	if while_mode:
		if add_command_to_script("while_right"):
			if command_list.item_count <= 4:
				command_list.add_item("while pas de mur → droite")
		while_mode = false
	else:
		if add_command_to_script("droite()"):
			if command_list.item_count <= 4:
				command_list.add_item("droite()")

func _on_btn_while_pressed() -> void:
	while_mode = true
	print("🌀 Mode while activé : choisis une direction")

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
	elif cmd == "while_up":
		await execute_while_move("up")
	elif cmd == "while_down":
		await execute_while_move("down")
	elif cmd == "while_left":
		await execute_while_move("left")
	elif cmd == "while_right":
		await execute_while_move("right")
	else:
		print("❌ Commande inconnue : ", cmd)

# --- While no wall ----------------------

func execute_while_move(direction: String) -> void:
	print("🔁 while pas de mur →", direction)
	while can_move_in_direction(direction):
		await move_one_step(direction)

func move_one_step(direction: String) -> void:
	match direction:
		"up":
			await move_up_animated()
		"down":
			await move_down_animated()
		"left":
			await move_left_animated()
		"right":
			await move_right_animated()

func can_move_in_direction(direction: String) -> bool:
	var new_x := grid_x
	var new_y := grid_y

	match direction:
		"up":
			new_y -= 1
		"down":
			new_y += 1
		"left":
			new_x -= 1
		"right":
			new_x += 1
		_:
			return false

	# On ne peut pas sortir du niveau
	if new_x < MIN_COL or new_x > MAX_COL or new_y < MIN_ROW or new_y > MAX_ROW:
		return false

	# On ne peut pas aller sur une case obstacle
	return not is_blocked(new_x, new_y)

# ========================================
# MOUVEMENTS ANIMÉS AVEC LIMITES + OBSTACLES
# ========================================

# Cases bloquées (murs)
var obstacles = [
	Vector2(3, 1),
	Vector2(3, 2),
	Vector2(3, 3)
]

func is_blocked(x: int, y: int) -> bool:
	return Vector2(x, y) in obstacles

func move_up_animated():
	var new_y = grid_y - 1
	
	if new_y < MIN_ROW or is_blocked(grid_x, new_y):
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
	
	if new_y > MAX_ROW or is_blocked(grid_x, new_y):
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
	
	if new_x < MIN_COL or is_blocked(new_x, grid_y):
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
	
	if new_x > MAX_COL or is_blocked(new_x, grid_y):
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
	while_mode = false

func reset_player_position():
	grid_x = 0
	grid_y = 2
	
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
	if grid_x == 6 and grid_y == 2:
		print("🎉 VICTOIRE !")
		show_victory_screen()
	else:
		print("Position actuelle : (", grid_x, ", ", grid_y, ")")

func show_victory_screen():
	get_tree().change_scene_to_file("res://world_1.tscn")
	print("✨ Niveau terminé !")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://world_1.tscn")


func _on_info_button_pressed() -> void:
	SceneManager.go_to_scene("res://information1.tscn")
