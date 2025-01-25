extends Node


# Called when the node enters the scene tree for the first time.
func _ready() -> void: 
	generateColorSwap("res://art/characters/5_basic_moto/char_moto.png", "res://art/colorSwapMap.bmp", Color("#fb9a99"), Color("#e31a1c"))
	pass # Replace with function body.


func generateColorSwap(ref_image_path:String, color_swap_palet_path:String, lightColor:Color, darkColor:Color) -> void :
	
	# Load the source image and the color palet 
	var image:Image = Image.load_from_file(ref_image_path)
	var color_swap_palet:Image = Image.load_from_file(color_swap_palet_path)
	
	# get the amount of new images to create
	var color_swap_num:int = color_swap_palet.get_width();
	for i:int in range(color_swap_num):
		# copy the image
		var color_swap_image:Image = Image.create_from_data(image.get_width(), image.get_height(), false, image.get_format(), image.get_data());
		
		# color swap the concerned pixels
		for pixel_y:int in range(image.get_height()):
			for pixel_x:int in range(image.get_width()):
				if(color_swap_image.get_pixel(pixel_x, pixel_y)  == lightColor) :
					color_swap_image.set_pixel(pixel_x, pixel_y, color_swap_palet.get_pixel(i, 0));
				elif(color_swap_image.get_pixel(pixel_x, pixel_y)  == darkColor) :
					color_swap_image.set_pixel(pixel_x, pixel_y, color_swap_palet.get_pixel(i, 1));
		
		# save the alt image
		var path_out:String = ref_image_path.substr(0,ref_image_path.length()-4)+"_alt"+str(i)+".png";
		color_swap_image.save_png(path_out);		
	
