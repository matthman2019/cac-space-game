shader_type canvas_item;

instance uniform vec3 hairColor = vec3(1, 0, 0);
instance uniform vec3 skinColor = vec3(0, 1, 0);
instance uniform vec3 eyeColor = vec3(0, 0, 1);
instance uniform vec3 primaryColor = vec3(1, 1, 0);
instance uniform vec3 secondaryColor = vec3(0, 1, 1);
instance uniform vec3 tertiaryColor = vec3(1, 0, 1);
const float colorVals[6] = float[6](0.0, 0.166, 0.333, 0.5, 0.666, 0.833);
const float diffErr = 0.05;


bool diff(float num1, float num2) {
	return (abs(num1 - num2) < diffErr);
}

void fragment() {
	float shade = COLOR.b;
	vec3 colors[6] = vec3[6](hairColor, skinColor, eyeColor, primaryColor, secondaryColor, tertiaryColor);
	
	COLOR.rgb = vec3(1.0, 0.0, 0.0);
	for (int i = 0; i < 6; i++) {
		if (diff(shade, colorVals[i])) {
			COLOR.rgb = colors[i];
			break;
		}
	}
	
}
