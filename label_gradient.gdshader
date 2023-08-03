shader_type canvas_item;
render_mode blend_mix;
uniform sampler2D gradient;

void fragment() {
	COLOR.a = texture(TEXTURE, UV).a;
	vec2 my_uv = vec2(UV.y * 10.0, 0.0);
	COLOR.rgb = COLOR.rgb * texture(gradient, my_uv).rgb;
}
