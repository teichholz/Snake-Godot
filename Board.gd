extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Tile { WALL, FRUIT, SNEK, CELL }


onready var screen : Vector2 = get_viewport().size
onready var map : TileMap = $TileMap

# these could be taken out of the project settings
var width = 1024
var height = 608
onready var cols = width / map.cell_size.x
onready var rows = height / map.cell_size.y

var snek = [] # Vector2s
var input_dir : Vector2 = Vector2(0, 1) # default go down

# input loop
var ctr_move : float = 0.0
var ctr_fruit : float = 0.0
var time_to_move : float = 0.4 # second
var time_to_fruit : float = 4.0 # second
var last_executed_input : Vector2

func _ready():
	reset()
	
func reset():
	init_snek(5, 5)
	draw_snek()
	draw_tilemap(true)
	ctr_move = 0
	ctr_fruit = 0
	input_dir = Vector2(0, 1)
	
func draw_tilemap(overwrite_fruits = false):
	for row in range(rows):
		for col in range(cols):
			if row == 0 || row == (rows - 1) || col == 0 || col == (cols - 1):
				set_cell(Vector2(col, row), Tile.WALL)
			else:
				var cell = map.get_cell(col, row)
				if (overwrite_fruits):
					set_cell(Vector2(col, row), Tile.CELL)
				if (cell != Tile.FRUIT):
					set_cell(Vector2(col, row), Tile.CELL)
				
func init_snek(x, y):
  snek = [Vector2(x, y)]

func snek_head_interact():
	var head = snek.front()
	var tile = map.get_cell(head.x, head.y)
	if tile == Tile.FRUIT:
		add_tail()
	if tile == Tile.WALL:
		reset()
	
	# snake death, check for 2 of the same vectors
	var sort = snek.duplicate()
	
	sort.sort()
	var last = sort.front()
	for vec in sort.slice(1, sort.size()):
		if last == vec:
			breakpoint
			reset()
			break
		last = vec
	
		
	
func spawn_fruit():
	var x = rand_range(0, cols)
	var y = rand_range(0, rows)
	var tile = map.get_cell(x, y)
	if (tile != Tile.WALL && tile != Tile.SNEK):
		set_cell(Vector2(x, y), Tile.FRUIT)
	else:
		spawn_fruit()

func draw_snek():
	for vec in snek:
		set_cell(vec, Tile.SNEK)
		
func draw():
	draw_tilemap()
	draw_snek()
	
func set_cell(pos : Vector2, type):
	map.set_cell(pos.x, pos.y, type)
	
func _process(delta):
	ctr_move += delta
	ctr_fruit += delta
	
	if ctr_fruit >= time_to_fruit:
		spawn_fruit()
		ctr_fruit = 0
		
	if ctr_move >= time_to_move:
		last_executed_input = input_dir
		move_snek(input_dir)
		snek_head_interact()
		draw()
		ctr_move = 0
		
func move_snek(dir : Vector2):
	var new_head = snek.front() + dir
	var new_tail = snek.slice(0, snek.size() - 2) if snek.size() > 1 else []
	snek = [new_head] + new_tail
	
func add_tail():
	var back = snek.back()
	var tail = back + input_dir * -1
	snek.push_back(tail)
	
func _input(event):
	if (Input.is_key_pressed(KEY_W)):
		input_dir = Vector2(0, -1)
	elif (Input.is_key_pressed(KEY_S)):
		input_dir = Vector2(0, 1)
	elif (Input.is_key_pressed(KEY_A)):
		input_dir = Vector2(-1, 0)
	elif (Input.is_key_pressed(KEY_D)):
		input_dir = Vector2(1, 0)
		
	if (last_executed_input + input_dir).length() == 0:
		input_dir = last_executed_input
