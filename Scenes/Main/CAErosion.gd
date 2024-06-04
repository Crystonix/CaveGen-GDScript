extends Node

class_name CAErosion

var grid:Array

#region setup
func _init(p_width:int = 128,p_height:int = 128, state:bool = false):
	var new_grid:Array
	for x in p_width:
		new_grid.append([])
		for y in p_height:
			new_grid[x].append([])
			new_grid[x][y] = state
	grid = new_grid

func generate_noise(noise_threshold:float = 0.45):
	for x in grid.size():
		for y in grid[x].size():
			grid[x][y] = noise_threshold < randf()

func clear_grid():
	for x in grid.size():
		for y in grid[x].size():
			grid[x][y] = false
#endregion

#region code
func erode(iterations:int = 1):
	assert (iterations != 0,"zero iterations")
	var new_grid:Array = grid.duplicate(true)
	for i in range(iterations):
		for x in range(grid.size()):
			for y in range(grid[0].size()):
				var neighbour_count:int = get_neighbour_count(x,y)
				var new_cell_state:bool
				if grid[x][y]:
					if neighbour_count < 4:
						new_cell_state = false 
					else: new_cell_state = true
				else:
					if neighbour_count > 4: 
						new_cell_state = true
					else: new_cell_state = false
					
				new_grid[x][y] = new_cell_state
		grid = new_grid

func get_neighbour_count(x:int,y:int) -> int:
	var count:int = 0
	for i in [-1,0,1]:
		for j in [-1,0,1]:
			if i == 0 and j == 0: 
				continue
			var nx:int = x + i
			var ny:int = y + j
			if nx >= 0 and nx < grid.size() and ny >= 0 and ny < grid[x].size():
				if grid[nx][ny]:
					count += 1
	return count
#endregion

#region get/set
func get_cell_state(x:int,y:int):
	return grid[x][y]

func get_GRID_WIDTH():
	return grid.size()

func get_GRID_HEIGHT():
	return grid[0].size()
#endregion
