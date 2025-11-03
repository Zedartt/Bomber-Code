extends Node

@onready var tilemap := $TileMap
@onready var player := $CharacterBody2D

const GRID_WIDTH := 7
const GRID_HEIGHT := 5
const CELL_SIZE := 77

# Offset pour suivre la position du TileMap
var tilemap_offset := Vector2.ZERO

func _on_back_pressed() -> void:
	get_tree().change_scene_to_file("res://world_1.tscn")

func _ready():
	# Récupère automatiquement la position du TileMap
	tilemap_offset = tilemap.position
	print("Offset du TileMap : ", tilemap_offset)
	
	_place_player()
	_place_door()

func _place_player():
	# Position de base
	var grid_pos = Vector2(
		(GRID_WIDTH - 1) * CELL_SIZE + CELL_SIZE / 2.0,
		(GRID_HEIGHT - 1) * CELL_SIZE + CELL_SIZE / 2.0
	)
	
	# Applique l'offset du TileMap
	player.position = grid_pos + tilemap_offset
	print("Position joueur : ", player.position)

func _place_door():
	var door = Sprite2D.new()
	door.texture = load("res://images/door.png")
	
	# Position de base
	var grid_pos = Vector2(
		(GRID_WIDTH - 1) * CELL_SIZE + CELL_SIZE / 2.0,
		CELL_SIZE / 2.0
	)
	
	# Applique l'offset du TileMap
	door.position = grid_pos + tilemap_offset
	
	# Redimensionne la porte
	if door.texture:
		var texture_size = door.texture.get_size()
		var scale_factor = CELL_SIZE / max(texture_size.x, texture_size.y)
		door.scale = Vector2(scale_factor, scale_factor)
	
	add_child(door)
	print("Position porte : ", door.position)
