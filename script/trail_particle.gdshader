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
	COLOR.rgb = color.rgb * circle(UV, 1, 0.2);
	// Called for every pixel the material is visible on.
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
