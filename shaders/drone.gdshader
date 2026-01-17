shader_type canvas_item;

uniform float flash_strength : hint_range(0.0, 1.0) = 0.0;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 original_color = texture(TEXTURE, UV);

	vec3 flashed_rgb = mix(original_color.rgb, vec3(1.0), flash_strength);
	COLOR = vec4(flashed_rgb, original_color.a);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
