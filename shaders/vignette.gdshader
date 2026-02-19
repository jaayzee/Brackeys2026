shader_type canvas_item;

void vertex() {
}

uniform float vignetteSize = 1.0;

uniform vec4 vignetteColor = vec4(0,0,0,1);

uniform vec4 vignetteSinSettings = vec4(0,0,0,0);
uniform vec4 vignetteCosSettings = vec4(0,0,0,0);

uniform vec4 deformationSettings = vec4(0,0,0,0);
uniform sampler2D vignetteTexture;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;

void fragment() {

		float xSin = sin(SCREEN_UV.x * vignetteSinSettings.x + TIME*vignetteSinSettings.y);
		float ySin = sin(SCREEN_UV.y * vignetteSinSettings.z + TIME*vignetteSinSettings.w);
		float xCos = cos(SCREEN_UV.x * vignetteCosSettings.x + TIME*vignetteCosSettings.y);
		float yCos = cos(SCREEN_UV.y * vignetteCosSettings.z + TIME*vignetteCosSettings.w);

		vec2 uv = SCREEN_UV - vec2(.5,.5);
		float ratio = SCREEN_PIXEL_SIZE.x/SCREEN_PIXEL_SIZE.y;

		uv.y *= ratio;

		float mask = length(uv);
		mask += xSin *  deformationSettings.x + ySin *  deformationSettings.y + xCos *  deformationSettings.z + yCos *  deformationSettings.w;
		mask = step(mask,vignetteSize);

		COLOR = mix(texture(vignetteTexture,SCREEN_UV),texture(screen_texture,SCREEN_UV),mask * vignetteColor.a);
}