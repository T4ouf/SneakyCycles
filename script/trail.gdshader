shader_type canvas_item;

uniform vec4 color : source_color;

float circle(vec2 position, float radius, float feather)
{
	return smoothstep(radius, radius + feather, dot(position, position) * 4.0);
}

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR.rgb *= circle(UV - vec2(0.5, 0.5), 0.4, 0.005);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
