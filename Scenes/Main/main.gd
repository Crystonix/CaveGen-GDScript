@tool
extends Node2D

#region Variables
@export_category("Exports")
@export var texture_rect:TextureRect
@export var timer:Timer

@export_category("Grid")
@export_range(10,1024,1) var GRID_SIZE:int = 128
@export_range(0,1,0.05) var noise_threshold:float = 0.45

@export_category("CA")
@export_color_no_alpha var c_true = Color.WHITE;
@export_color_no_alpha var c_false = Color.BLACK;

@export_category("Erosion")
@export var step_size:int = 1
@export_range(0.01,4,0.01) var speed_mod:float = 0.01
@export_range(1,100,.1) var erode_batch_size:int = 5

var ca:CAErosion;
#endregion

#region Code
func _ready():
	ca = CAErosion.new(GRID_SIZE,GRID_SIZE,false)
	ca.generate_noise(noise_threshold)
	update_texture(ca)

func update_texture(p_ca:CAErosion):
	var image:Image = Image.create(p_ca.get_GRID_WIDTH(), p_ca.get_GRID_HEIGHT(), false, Image.FORMAT_RGB8) 
	
	for x in range(p_ca.get_GRID_WIDTH()):
		for y in range(p_ca.get_GRID_HEIGHT()):
			if p_ca.get_cell_state(x,y) == true:
				image.set_pixel(x, y,c_true)
			else:
				image.set_pixel(x,y,c_false)
	texture_rect.set_texture(ImageTexture.create_from_image(image))
#endregion

#region Signals
func _on_erode_button_pressed():
	var start = Time.get_ticks_usec()
	ca.erode(erode_batch_size)
	var end = Time.get_ticks_usec()
	print("erode-time: ",(end-start)/1000000.0)
	update_texture(ca)

func _on_init_button_pressed():
	ca.clear_grid()
	ca.generate_noise(noise_threshold)
	update_texture(ca)

func _on_start_erosion_button_pressed():
	timer.start(1 * speed_mod)

func _on_stop_erosion_button_pressed():
	timer.stop()

func _on_timer_timeout():
	ca.erode(step_size)
	update_texture(ca)
#endregion



