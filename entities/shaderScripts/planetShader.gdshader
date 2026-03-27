shader_type canvas_item;

uniform vec3 darkColor = vec3(0, 0, 0);
uniform vec3 lightColor = vec3(1, 1, 1);
uniform bool rainbow = false;

// taken from gemini
// Function to convert RGB (vec3) to HSV (vec3)
vec3 rgb2hsv(vec3 c) {
    vec4 K = vec4(0.0, -1.0 / 3.0, 2.0 / 3.0, -1.0);
    vec4 p = mix(vec4(c.bg, K.wz), vec4(c.gb, K.xy), step(c.b, c.g));
    vec4 q = mix(vec4(p.xyw, c.r), vec4(c.r, p.yzx), step(p.x, c.r));
    float d = q.x - min(q.w, q.y);
    float e = 1e-10;
    return vec3(abs(q.x + p.y) > e ? q.z + (q.w - q.y) / d : K.z + (q.y - q.r) / d, d / (q.x + e), q.x);
}
vec3 hsb2rgb(vec3 c) {
    vec4 K = vec4(1.0, 2.0 / 3.0, 1.0 / 3.0, 3.0);
    vec3 p = abs(fract(c.xxx + K.xyz) * 6.0 - K.www);
    return c.z * mix(K.xxx, clamp(p - K.xxx, 0.0, 1.0), c.y);
}

void fragment() {
	float originalAlpha = COLOR.a;
	float weight = length(COLOR.x);
	COLOR = vec4(mix(darkColor, lightColor, weight), originalAlpha);
	
	if (rainbow) {
		float currentHue = rgb2hsv(COLOR.xyz).b;
		// thanks to gemini!
		float hueMod = mod(TIME * 0.1, 1.0); 
		float newHue = mod(currentHue + hueMod, 1.0);
    	// Create RGB from HSB (Hue, 1.0 Saturation, 1.0 Brightness)
    	vec3 rgb_color = hsb2rgb(vec3(newHue, 1.0, 1.0));
		COLOR = vec4(rgb_color, originalAlpha);
	}
}
