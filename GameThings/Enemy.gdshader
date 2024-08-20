shader_type canvas_item;
uniform vec3 tint = vec3(1,1,1);
uniform vec3 slowTint = vec3(1,1,1);


void vertex() {
  VERTEX.xy += vec2(sin((TIME/5.0)*VERTEX.y)/0.2,sin((TIME/8.0)*VERTEX.x)/0.2);
}

void fragment() {
	vec4 color = texture(TEXTURE,UV);
	COLOR = vec4(slowTint * tint * color.rgb, color.a);
}

//void light() {
	// Called for every pixel for every light affecting the CanvasItem.
	// Uncomment to replace the default light processing function with this one.
//}
