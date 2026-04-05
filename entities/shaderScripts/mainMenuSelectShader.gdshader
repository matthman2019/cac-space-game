// thanks to gemini for helping with the blur
shader_type canvas_item;

// Define a slider in the inspector to control blur strength
uniform float blurAmount : hint_range(0.0, 5.0) = 0.0;
uniform float darknessAmount : hint_range(0.0, 1.0) = 0.0;

// Access the screen texture with mipmaps enabled
// hint_screen_texture makes previously-rendered effects show,
// filter_linear_minimap lets it blend nearest pixels
uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;

void fragment() {
    // textureLod samples a specific Level of Detail (mipmap)
	// textureLOD lets us sample, blur_amount is basically how blurred it is
    vec4 color = textureLod(screen_texture, SCREEN_UV, blurAmount);
	color.rgb = clamp(color.rgb - vec3(darknessAmount), 0.0, 1.0);
    COLOR = color;
}
