shader_type canvas_item;
render_mode unshaded;

uniform vec4 base_color : hint_color = vec4(1.0);
uniform vec4 adjust_color : hint_color = vec4(1.0);

void fragment() {
	float alpha_value = texture(TEXTURE, UV).a;
	
	vec4 adjusted_color = vec4(adjust_color.rgb, alpha_value);
	
	vec4 overlayed_color_on_base = mix(adjusted_color, base_color, 1.0 - alpha_value);
	
	COLOR = overlayed_color_on_base;
}