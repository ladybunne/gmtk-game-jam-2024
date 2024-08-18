shader_type canvas_item;
uniform vec4 color : source_color = vec4(1.0);
uniform float frequency = 8.0; 
uniform float speed = 1.0;

void fragment() {
	
	vec2 pos = UV - vec2(0.5);
	float angle = atan(pos.y, pos.x);
	if (angle < 0.0) {
		angle += 2.0 * PI;
	}
	
	float wave = 0.5 * sin(frequency * angle + TIME * speed) + 0.5;
	wave = step(0.5,wave);
	COLOR = vec4(1,1,1,wave * texture(TEXTURE, UV).a);
}
