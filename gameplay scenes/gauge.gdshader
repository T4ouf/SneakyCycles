//shader_type spatial;
shader_type canvas_item;
//render_mode cull_disabled;

void vertex() {
	// Called for every vertex the material is visible on.
}

uniform float amt : hint_range(0.0, 1.0);
uniform vec4 color : source_color;

void fragment() 
{
	if (distance(UV, vec2(0.5,0.5)) > amt/2.0 || distance(UV, vec2(0.5, 0.5)) < 0.4) 
	{
		COLOR = vec4(0.0);
	}
	else 
	{
		COLOR = vec4(color);
	}
}

//uniform vec3 colorPlayer : source_color;

//void fragment() 
//{
//	ALBEDO = colorPlayer;
//}

void light() {
	// Called for every pixel for every light affecting the CanvasItem.
}
