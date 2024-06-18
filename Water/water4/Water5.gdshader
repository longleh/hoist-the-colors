shader_type canvas_item;

uniform vec2 tile_factor = vec2(1,1);
uniform float aspect_ratio = 0.5;

uniform vec2 time_factor = vec2(3, 3);
uniform vec2 offset_factor = vec2(0.4, 0.5);
uniform vec2 amplitude = vec2(0.05, 0.2);

void fragment() {
	vec2 tiled_uvs = UV * tile_factor;
	tiled_uvs.y *= aspect_ratio;
	
	vec2 waves_uv_offset;
	waves_uv_offset.x = cos(TIME * time_factor.x + (tiled_uvs.x + tiled_uvs.y) * offset_factor.x);
	waves_uv_offset.y = cos(TIME * time_factor.y + (tiled_uvs.x + tiled_uvs.y) * offset_factor.y);
	COLOR = texture(TEXTURE, tiled_uvs + waves_uv_offset * amplitude);
	//COLOR = COLOR;
//	COLOR = vec4(wave_uv_offset, vec2(0.0, 1.0));
//	COLOR = vec4(UV * aspect_ratio, vec2(0.0, 1.0));
}