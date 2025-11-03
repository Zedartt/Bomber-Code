extends Node

const GRID_WIDTH := 7
const GRID_HEIGHT := 5
const CELL_SIZE := 64

var grid = []

func _ready():
	_init_grid()

func _init_grid():
	grid.clear()
	for y in range(GRID_HEIGHT):
		var row = []
		for x in range(GRID_WIDTH):
			row.append("empty")
		grid.append(row)

func get_cell(x: int, y: int) -> String:
	return grid[y][x]

func set_cell(x: int, y: int, value: String) -> void:
	grid[y][x] = value
