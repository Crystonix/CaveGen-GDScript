@tool
extends Node2D
@export_category("Exports")
@export var texture_rect:TextureRect
@export var cam:Camera2D

@export_category("Grid")
@export var GRID_SIZE:Vector2 = Vector2(512,512)
@export_range(0,1,0.05) var init_threshold:float = 0

@export_category("CA")
@export_range(0,50,1) var Iterations:int = 0
@export_range(0.1,0.5,0.1) var animation:float = 0.1

var voxel_data:Array = []

func _ready():
	voxel_data = generate_initial_voxel_data(GRID_SIZE)
	update_texture(voxel_data)
	
	
func generate_initial_voxel_data(grid:Vector2) -> Array:
	var voxel_data:Array = []
	for x in range(grid.x):
		voxel_data.append([])
		for y in range(grid.y):
			voxel_data[x].append([])
			if randf() < init_threshold:
				voxel_data[x][y].append(255)
			else:
				voxel_data[x][y].append(0)
	return voxel_data
	
func create_texture_from_voxel_data(voxel_data:Array) -> ImageTexture:
	var width:int = voxel_data.size()
	var height:int = voxel_data[0].size()
	
	var image = Image.create(width, height, false, Image.FORMAT_RGB8)
	
	for x in range(width):
		for y in range(height):
			var color_value = voxel_data[x][y][0]
			image.set_pixel(x, y, Color(color_value / 255.0, color_value / 255.0, color_value / 255.0))
	return ImageTexture.create_from_image(image)

func apply_ca_rules(iterations:int, data:Array) -> Array:
	if iterations <= 0:
		print("finished iterating")
		return data
	else:
		var updated_grid:Array
		for x in range(GRID_SIZE.x):
			updated_grid.append([])
			for y in range(GRID_SIZE.y):
				updated_grid[x].append([])
				var neighbour_count:int = count_neighbours(data,x,y)
				if data[x][y][0] > 0:
					updated_grid[x][y].append(0 if neighbour_count < 4 else 255)
				else:
					updated_grid[x][y].append(255 if neighbour_count > 4 else 0)
		update_texture(updated_grid)
		await get_tree().create_timer(animation).timeout
		print("grid update")
		return await apply_ca_rules(iterations-1,updated_grid)

func update_texture(p_data:Array):
	texture_rect.set_texture(create_texture_from_voxel_data(p_data))

func count_neighbours(grid:Array,x:int,y:int) -> int:
	var count:int = 0
	for i in range(-1,2):
		for j in range(-1,2):
			if i == 0 and j == 0:
				continue
			var nx = x + i
			var ny = y + j
			if nx >= 0 and nx < GRID_SIZE.x and ny >=0 and ny < GRID_SIZE.y:
				if grid[nx][ny][0] > 0:
					count += 1
	#print("count: ",count)
	return count

func sample_voxel_texture(texture: ImageTexture, uv: Vector2) -> bool:
	var image:Image = texture.get_image()
	var size = image.get_size()
	var pixel:Color = image.get_pixelv(Vector2(uv) * Vector2(size))
	return (pixel.r > 0.5)


func _on_start_button_pressed():
	voxel_data = await apply_ca_rules(Iterations, voxel_data)
	update_texture(voxel_data)


func _on_init_new_button_pressed():
	voxel_data = generate_initial_voxel_data(GRID_SIZE)
	update_texture(voxel_data)


func _on_animation_h_slider_value_changed(value):
	animation = value
	$CanvasLayer/UI/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/Number.set_text(str(value))
