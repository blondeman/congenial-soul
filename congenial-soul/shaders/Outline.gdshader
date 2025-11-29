shader_type spatial;
render_mode cull_front, unshaded;

uniform vec3 outline_color : source_color = vec3(0,0,0);
uniform float outline_thickness : hint_range(0.0, 1.0, 0.01) = 0.05;

void vertex() {
	VERTEX += outline_thickness*NORMAL;
}

void fragment() {
	ALBEDO = outline_color;
}