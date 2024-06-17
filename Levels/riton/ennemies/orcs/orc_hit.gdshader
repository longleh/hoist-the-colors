shader_type canvas_item;

uniform bool hit = false;
uniform bool death = true;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 new_color = previous_color;
	if (hit == true) {
		vec4 hit_color = vec4(0.57, 0, 0, previous_color.a);
		new_color = hit_color;
	} else if (death == true) {
		vec4 death_color = vec4(0, 0, 0, previous_color.a);
		new_color = death_color;
	}
	COLOR = new_color;
}
