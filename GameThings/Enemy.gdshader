shader_type canvas_item;
uniform vec3 tint = vec3(1,1,1);

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 color = texture(TEXTURE,UV);
	COLOR = vec4(tint * color.rgb, color.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
