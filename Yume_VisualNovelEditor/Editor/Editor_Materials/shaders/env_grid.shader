shader_type spatial;
//render_mode unshaded;

uniform sampler2D grid_text;
uniform float grid_scale : hint_range(0.1, 100) = 20;

uniform vec4 grid_color : hint_color = vec4(vec3(1.0), 1.0);
uniform vec4 bg_color : hint_color = vec4(vec3(1.0), 1.0);



void fragment() {
	vec4 grid = texture(grid_text, UV * grid_scale);
	
	if (grid.r > 0.3){
		grid = grid_color;
	} else {
		grid = bg_color;
	}
	
	ALBEDO = grid.rgb;
	EMISSION = grid.rgb;
}