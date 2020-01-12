shader_type spatial;
render_mode unshaded;

uniform float transition_amount : hint_range(0, 1) = 0;
uniform sampler2D empty_base;
uniform sampler2D image_a;
uniform sampler2D image_b;


vec3 _transition_images(vec3 color_a, vec3 color_b){
	vec3 mixed_image_result = mix(color_a.rgb, color_b.rgb, transition_amount);
	return mixed_image_result;
}


void fragment() {
	ALBEDO = _transition_images( texture(image_a, UV).rgb, texture(image_b, UV).rgb );
	
}