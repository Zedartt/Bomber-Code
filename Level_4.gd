extends Node

@onready var tilemap := $TileMap
@onready var player := $CharacterBody2D
@onready var sprite_2d: AnimatedSprite2D = $Sprite2D
@onready var anim: AnimatedSprite2D = $CharacterBody2D/Sprite2D
@onready var command_list : ItemList = $TextureRect/ItemList

const GRID_WIDTH := 7
const GRID_HEIGHT := 7
const CELL_SIZE := 64
const MAX_SCRIPT_LINES := 6

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

var bomb_positions = []
# Mode while : le prochain clic sur une direction crée un bloc while_xxx
var while_mode: bool = false

func _ready():
	tilemap_offset = tilemap.position
	_place_player()
	_place_door()
	_place_bombs()

func _place_player():
	grid_x = 6
	grid_y = 2  # le joueur est à la case (0, 2)
	
	var grid_pos = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	player.position = grid_pos + tilemap_offset
	current_position = player.position
	print("🎮 Joueur placé à la case (0, 2)")


func _place_door():
	var door = Sprite2D.new()
	door.texture = load("res://images/door.png")
	
	var grid_x = 0
	var grid_y = 3    # la porte est à la case (6, 2)
	
	var grid_pos = Vector2(
		grid_x * CELL_SIZE + CELL_SIZE / 2.0,
		grid_y * CELL_SIZE + CELL_SIZE / 2.0
	)
	door.position = grid_pos + tilemap_offset
	
	if door.texture:
		var texture_size = door.texture.get_size()
		var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
		door.scale = Vector2(scale_factor, scale_factor)
	
	add_child(door)
	print("🚪 Porte placée à la case (6, 2)")
	

func _place_bombs():
	bomb_positions = [
		Vector2(1, 1),
		Vector2(1, 2),
		Vector2(1, 5),
		Vector2(3, 2),
		Vector2(3, 3),
		Vector2(5, -1),
		Vector2(5, 2),
		Vector2(5, 3),
		Vector2(6, 4)
	]
	
	for pos in bomb_positions:
		var bomb = Sprite2D.new()
		bomb.texture = load("res://images/bomb_state2.png")
		
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
		print("⚠️ Script plein ! Maximum 6 lignes")
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
			if command_list.item_count <= 5:
				command_list.add_item("while_no_wall → up")
		while_mode = false
	else:
		if add_command_to_script("move_up()"):
			if command_list.item_count <= 5:
				command_list.add_item("move_up()")

func _on_btn_down_pressed():
	if while_mode:
		if add_command_to_script("while_down"):
			if command_list.item_count <= 5:
				command_list.add_item("while_no_wall → down")
		while_mode = false
	else:
		if add_command_to_script("move_down()"):
			if command_list.item_count <= 5:
				command_list.add_item("move_down()")

func _on_btn_left_pressed():
	if while_mode:
		if add_command_to_script("while_left"):
			if command_list.item_count <= 5:
				command_list.add_item("while_no_wall → left")
		while_mode = false
	else:
		if add_command_to_script("move_left()"):
			if command_list.item_count <= 5:
				command_list.add_item("move_left()")

func _on_btn_right_pressed():
	if while_mode:
		if add_command_to_script("while_right"):
			if command_list.item_count <= 5:
				command_list.add_item("while_no_wall → right")
		while_mode = false
	else:
		if add_command_to_script("move_droite()"):
			if command_list.item_count <= 5:
				command_list.add_item("move_droite()")

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
	
	if cmd == "move_up()":
		await move_up_animated()
	elif cmd == "move_down()":
		await move_down_animated()
	elif cmd == "move_left()":
		await move_left_animated()
	elif cmd == "move_right()":
		await move_right_animated()
	elif cmd == "while_up":
		await execute_while_move("up")
		return  # Le check est déjà dans move_one_step()
	elif cmd == "while_down":
		await execute_while_move("down")
		return
	elif cmd == "while_left":
		await execute_while_move("left")
		return
	elif cmd == "while_right":
		await execute_while_move("right")
		return
	else:
		print("❌ Commande inconnue : ", cmd)
		return
	
	# ✅ Vérifie la collision après chaque mouvement simple
	_check_bomb_collision()

# --- While no wall ----------------------

func execute_while_move(direction: String) -> void:
	print("🔁 while_no_wall →", direction)
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
	
	_check_bomb_collision()

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
	Vector2(2, 4),
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

	anim.play("up")

	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished

	anim.play("idle")
	
	# ✅ Vérifie si on a touché une bombe
	_check_bomb_collision()

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
	
	anim.play("down")
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished
	
	anim.play("idle")
	
	# ✅ Vérifie si on a touché une bombe
	_check_bomb_collision()

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
	
	anim.play("left")
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished
	
	anim.play("idle")
	
	# ✅ Vérifie si on a touché une bombe
	_check_bomb_collision()

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
	
	anim.play("right")
	
	var tween = get_tree().create_tween()
	tween.tween_property(player, "position", target, 0.3)
	current_position = target
	await tween.finished
	
	anim.play("idle")
	
	# ✅ Vérifie si on a touché une bombe
	_check_bomb_collision()

func _check_bomb_collision():
	var player_grid_pos = Vector2(grid_x, grid_y)
	
	for bomb_pos in bomb_positions:
		if player_grid_pos == bomb_pos:
			print("💥 BOOM ! Bombe touchée à la case (", grid_x, ", ", grid_y, ")")
			
			if anim:
				anim.play("death")  # Si tu as une animation de mort
				await get_tree().create_timer(0.1).timeout
			
			_on_reset_pressed()
			return
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
	grid_x = 6
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
	if grid_x == 0 and grid_y == 3:
		print("🎉 VICTOIRE !")
		show_victory_screen()
	else:
		print("Position actuelle : (", grid_x, ", ", grid_y, ")")

func show_victory_screen():
	get_tree().change_scene_to_file("res://world_1.tscn")
	print("✨ Niveau terminé !")

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://world_1.tscn")
	
func _on_info_button_pressed() -> void :
	SceneManager.go_to_scene("res://information1.tscn")
