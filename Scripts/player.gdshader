shader_type canvas_item;

uniform vec4 border_color : source_color = vec4(0.0, 0.0, 0.0, 1.0);
uniform float border_width : hint_range(0.0, 5.0) = 1.0;

void fragment() {
	vec4 base_color = texture(TEXTURE, UV);

	// If the current pixel is transparent, check neighbors for opaque pixels
	if (base_color.a == 0.0) {
		vec2 pixel = TEXTURE_PIXEL_SIZE * border_width;

		float max_alpha = max(
			max(texture(TEXTURE, UV + vec2(pixel.x, 0.0)).a,
				texture(TEXTURE, UV - vec2(pixel.x, 0.0)).a),
			max(texture(TEXTURE, UV + vec2(0.0, pixel.y)).a,
				texture(TEXTURE, UV - vec2(0.0, pixel.y)).a)
		);

		if (max_alpha > 0.0) {
			COLOR = border_color;
		} else {
			COLOR = base_color;
		}
	} else {
		COLOR = base_color;
	}
}
