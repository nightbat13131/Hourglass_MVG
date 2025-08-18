shader_type canvas_item;

uniform float outline_width = 1.0;
uniform vec4 outline_color : source_color;
uniform vec4 texture_region = vec4(0.0);
uniform vec4 modulate_color : source_color;
// https://godotshaders.com/shader/outline-for-atlas-texture-region/
// https://www.reddit.com/r/godot/comments/n8vxw3/how_to_create_a_shader_that_mimics_canvas_modulate/
void fragment() {
	vec4 color = texture(TEXTURE, UV);
	vec2 outline_offset = vec2(outline_width) * TEXTURE_PIXEL_SIZE;
	vec4 uv_region = vec4(texture_region.xy * TEXTURE_PIXEL_SIZE, texture_region.zw * TEXTURE_PIXEL_SIZE);

	// If texture region size was not specified, then use entire texture
	uv_region.zw = mix(vec2(1.0), uv_region.zw, ceil(uv_region.zw));

	float uv_offset;
	float a;
	float max_a = 0.0;

	uv_offset = UV.y - outline_offset.y;
	a = step(uv_region.y, uv_offset) * texture(TEXTURE, vec2(UV.x, uv_offset)).a;
	max_a = max(a, max_a);

	uv_offset = UV.y + outline_offset.y;
	a = step(uv_offset, uv_region.y + uv_region.w) * texture(TEXTURE, vec2(UV.x, uv_offset)).a;
	max_a = max(a, max_a);

	uv_offset = UV.x - outline_offset.x;
	a = step(uv_region.x, uv_offset) * texture(TEXTURE, vec2(uv_offset, UV.y)).a;
	max_a = max(a, max_a);

	uv_offset = UV.x + outline_offset.x;
	a = step(uv_offset, uv_region.x + uv_region.z) * texture(TEXTURE, vec2(uv_offset, UV.y)).a;
	max_a = max(a, max_a);
	if (outline_color.a <= 0.1) {COLOR = color*modulate_color;}
	else {COLOR = mix(color*modulate_color, outline_color, max_a - color.a);}

	
}
