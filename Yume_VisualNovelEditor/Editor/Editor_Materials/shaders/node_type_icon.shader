shader_type canvas_item;
render_mode unshaded;

uniform int index : hint_range(0,15) = 0;
uniform bool multiple = false;

uniform sampler2D TextureFrame;
uniform sampler2D Sprite2D;
uniform sampler2D AnimatedSprite2D;
uniform sampler2D Skeleton2D;
uniform sampler2D Sprite3D;
uniform sampler2D AnimatedSprite3D;
uniform sampler2D Skeleton3D;

uniform sampler2D AnimationPlayer;
uniform sampler2D AnimationTreePlayer;
uniform sampler2D SpriteFrames;

uniform sampler2D MultipleNodeMark;
uniform sampler2D ErrorMark;


void fragment() {
	vec4 image_base;
	vec2 uv_base = UV;
	float multiple_uv_ratio = 1.2;
	vec2 multiple_uv_offset = vec2(0,0.2);
	
	if (multiple && index < 9){
		uv_base = uv_base * multiple_uv_ratio - multiple_uv_offset;
	}
	
	if (index < 5){
		if (index == 0){
			image_base = texture(TextureFrame, uv_base);
		} else if (index == 1){
			image_base = texture(Sprite2D, uv_base);
		} else if (index == 2){
			image_base = texture(AnimatedSprite2D, uv_base);
		} else if (index == 3){
			image_base = texture(Skeleton2D, uv_base);
		} else if (index == 4){
			image_base = texture(Sprite3D, uv_base);
		}
	} else {
		if (index == 5){
			image_base = texture(AnimatedSprite3D, uv_base);
		} else if (index == 6){
			image_base = texture(Skeleton3D, uv_base);
		} else if (index == 7){
			image_base = texture(AnimationPlayer, uv_base);
		} else if (index == 8){
			image_base = texture(SpriteFrames, uv_base);
		} else if (index == 9){
			image_base = texture(AnimationTreePlayer, uv_base);
		} else if (index > 9){
			image_base = texture(ErrorMark, uv_base);
		}
	}
	
	if (multiple && index < 10){
		vec4 mixture;
		vec4 multiple_node_mark = texture(MultipleNodeMark, UV);
		
		if (multiple_node_mark.a > 0.0){
			mixture = mix(image_base, multiple_node_mark, 1.0);
		} else {
			mixture = image_base;
		}
		
		if (mixture.g > 0.9 && mixture.r > 0.9 && mixture.b < 0.8){
			mixture.a = 0.0;
		}
		
		if (UV.y > 0.5 && UV.x > 0.8){
			mixture.a = 0.0;
		} else if (UV.y < 0.2 && UV.x < 0.5) {
			mixture.a = 0.0;
		}
		
		
		COLOR = mixture;
	} else {
		COLOR = image_base;
	}
	
}