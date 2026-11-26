shader_type canvas_item;
// Draws a 1-texel outline around the solid pixels of a sprite.
// Pixels below alpha_threshold (like the soft drop shadows in the animal
// sheets) don't count as solid, so the shadow isn't outlined.
// The outline sits inside the sprite's frame, so frames need at least
// one transparent pixel of padding (the animal sheets have plenty).

uniform bool enabled = false;
uniform vec4 outline_color : source_color = vec4(1.0);
uniform float alpha_threshold : hint_range(0.0, 1.0) = 0.6;

void fragment() {
	vec4 tex = texture(TEXTURE, UV);
	COLOR *= tex;

	if (enabled && tex.a < alpha_threshold) {
		vec2 px = TEXTURE_PIXEL_SIZE;
		float neighbour = max(
			max(texture(TEXTURE, UV + vec2(px.x, 0.0)).a, texture(TEXTURE, UV - vec2(px.x, 0.0)).a),
			max(texture(TEXTURE, UV + vec2(0.0, px.y)).a, texture(TEXTURE, UV - vec2(0.0, px.y)).a));
		if (neighbour >= alpha_threshold) {
			COLOR = outline_color;
		}
	}
}
