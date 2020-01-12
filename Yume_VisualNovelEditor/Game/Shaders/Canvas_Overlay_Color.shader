shader_type canvas_item;
render_mode unshaded;

uniform vec4 color : hint_color = vec4(vec3(0.0), 1.0);



void fragment() {
	COLOR = color;
}