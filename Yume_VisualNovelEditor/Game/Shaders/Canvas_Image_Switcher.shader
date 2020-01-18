shader_type canvas_item;
render_mode unshaded;

uniform float transition_amount : hint_range(0, 1) = 0;
uniform sampler2D image_a;
uniform sampler2D image_b;
uniform float modulate_amount : hint_range(0, 1) = 0;
uniform vec4 modulate_color : hint_color = vec4(1.0);

uniform bool image_a_empty = false;
uniform bool image_b_empty = false;
uniform vec4 empty_color : hint_color = vec4(vec3(0.0),1.0);



vec4 transition_images(vec4 color_a, vec4 color_b) {
	vec4 mixed_image_result = mix(color_a, color_b, transition_amount);
	return mixed_image_result;
}

vec4 modulate (vec4 color) {
	vec4 modulated_image = mix(color, modulate_color, modulate_amount);
	return modulated_image;
}


void fragment() {
	vec4 image_a_color;
	vec4 image_b_color;
	
	if (image_a_empty){
		image_a_color = empty_color;
	} else {
		image_a_color = texture(image_a, UV);
	}
	
	if (image_b_empty){
		image_b_color = empty_color;
	} else {
		image_b_color = texture(image_b, UV);
	}
	
	vec4 first_pass = transition_images( image_a_color, image_b_color );
	
	vec4 second_pass = modulate(first_pass);
	
	COLOR = second_pass;
}