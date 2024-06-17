shader_type canvas_item;

uniform bool invulnerable = false;
uniform bool dead = false;
uniform bool heal = true;

void fragment() {
	vec4 previous_color = texture(TEXTURE, UV);
	vec4 new_color = previous_color;
	if (heal == true) {
		vec4 heal_color = vec4(0, 0.6, 0, previous_color.a);
		new_color = heal_color;
	}
	else if (invulnerable == true) {
		vec4 hit_color = vec4(1, 1, 1, previous_color.a);
		new_color = hit_color;
	}
	else if (dead == true) {
		vec4 death_color = vec4(0, 0, 0, previous_color.a);
		new_color = death_color;
	}
	COLOR = new_color;
}
