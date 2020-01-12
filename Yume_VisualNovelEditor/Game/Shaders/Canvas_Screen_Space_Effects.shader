shader_type canvas_item;
render_mode unshaded;



uniform vec4 modulate_color : hint_color = vec4(1.0);



vec4 modulate_canvas(vec4 fragment) {
	return fragment * modulate_color;
}


void fragment() {
	vec4 modulation_step = modulate_canvas(texture(SCREEN_TEXTURE, SCREEN_UV));
	COLOR = modulation_step;
}
