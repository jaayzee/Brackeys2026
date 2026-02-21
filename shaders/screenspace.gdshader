shader_type spatial;
render_mode unshaded,  depth_test_disabled;

// Edge highlight constnats
uniform sampler2D DEPTH_TEXTURE : hint_depth_texture, filter_linear_mipmap;
uniform sampler2D SCREEN_TEXTURE : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D NORMAL_TEXTURE : hint_normal_roughness_texture, filter_nearest;

uniform bool shadows_enabled = true;
uniform bool highlights_enabled = true;
uniform float shadow_strength : hint_range(0.0, 1.0, 0.01) = 0.4;
uniform float highlight_strength : hint_range(0.0, 1.0, 0.01) = 0.1;
uniform vec3 highlight_color : source_color = vec3(1.);
uniform vec3 shadow_color : source_color = vec3(0.0);

// B&W constants
uniform bool bw_enabled = true;
uniform float contrast : hint_range(0.5, 2.0) = 1.0;
uniform float brightness : hint_range(0.0, 2.0) = 1.0;

// Rain constants
uniform bool rain_enabled = true;
uniform float rain_speed : hint_range(0.1, 50.0) = 20.0;
uniform float rain_spacing : hint_range(10.0, 100.0) = 10.0;
uniform float streak_length : hint_range(0.05, 10) = 1;
uniform float streak_width : hint_range(0.0005, 0.1) = 0.01;
uniform float drop_brightness : hint_range(0.1, 1.0) = 0.5;

varying mat4 model_view_matrix;

float getDepth(vec2 screen_uv, sampler2D depth_texture, mat4 inv_projection_matrix){
	float raw_depth = texture(depth_texture, screen_uv)[0];
	vec3 normalized_device_coordinates = vec3(screen_uv * 2.0 - 1.0, raw_depth);
    vec4 view_space = inv_projection_matrix * vec4(normalized_device_coordinates, 1.0);	
	view_space.xyz /= view_space.w;	
	return -view_space.z;
}

float normalIndicator(vec3 normalEdgeBias, vec3 baseNormal, vec3 newNormal, float depth_diff){
	float normalDiff = dot(baseNormal - newNormal, normalEdgeBias);
	float normalIndicator = clamp(smoothstep(-.01, .01, normalDiff), 0.0, 1.0);
	float depthIndicator = clamp(sign(depth_diff * .25 + .0025), 0.0, 1.0);
	return (1.0 - dot(baseNormal, newNormal)) * depthIndicator * normalIndicator;
}

float random(vec2 uv) {
	return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void vertex(){
    model_view_matrix = VIEW_MATRIX * mat4(INV_VIEW_MATRIX[0], INV_VIEW_MATRIX[1], INV_VIEW_MATRIX[2], MODEL_MATRIX[3]);
}

void fragment() {
	vec2 e = vec2(1./VIEWPORT_SIZE.xy);
	
	// EDGE HIGHLIGHT
	float depth_diff = 0.0;
	float neg_depth_diff = .5;
	if (shadows_enabled) {
		float depth = getDepth(SCREEN_UV, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float du = getDepth(SCREEN_UV+vec2(0., -1.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dr = getDepth(SCREEN_UV+vec2(1., 0.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dd = getDepth(SCREEN_UV+vec2(0., 1.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		float dl = getDepth(SCREEN_UV+vec2(-1., 0.)*e, DEPTH_TEXTURE, INV_PROJECTION_MATRIX);
		depth_diff += clamp(du - depth, 0., 1.);
		depth_diff += clamp(dd - depth, 0., 1.);
		depth_diff += clamp(dr - depth, 0., 1.);
		depth_diff += clamp(dl - depth, 0., 1.);
		neg_depth_diff += depth - du;
		neg_depth_diff += depth - dd;
		neg_depth_diff += depth - dr;
		neg_depth_diff += depth - dl;
		neg_depth_diff = clamp(neg_depth_diff, 0., 1.);
		neg_depth_diff = clamp(smoothstep(0.5, 0.5, neg_depth_diff)*10., 0., 1.);
		depth_diff = smoothstep(0.2, 0.3, depth_diff);
	}
	
	float normal_diff = 0.;
	if (highlights_enabled) {
		vec3 normal = texture(NORMAL_TEXTURE, SCREEN_UV).rgb * 2.0 - 1.0;
		vec3 nu = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(0., -1.)*e).rgb * 2.0 - 1.0;
		vec3 nr = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(1., 0.)*e).rgb * 2.0 - 1.0;
		vec3 nd = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(0., 1.)*e).rgb * 2.0 - 1.0;
		vec3 nl = texture(NORMAL_TEXTURE, SCREEN_UV+vec2(-1., 0.)*e).rgb * 2.0 - 1.0;
		vec3 normal_edge_bias = (vec3(1., 1., 1.));
		normal_diff += normalIndicator(normal_edge_bias, normal, nu, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nr, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nd, depth_diff);
		normal_diff += normalIndicator(normal_edge_bias, normal, nl, depth_diff);
		normal_diff = smoothstep(0.2, 0.8, normal_diff);
		normal_diff = clamp(normal_diff-neg_depth_diff, 0., 1.);
	}
	
	vec3 original_color = texture(SCREEN_TEXTURE, SCREEN_UV).rgb;
	vec3 final_highlight_color = mix(original_color, highlight_color, highlight_strength);
	vec3 final_shadow_color = mix(original_color, shadow_color, shadow_strength);
	vec3 final = original_color;
	if (highlights_enabled) {
		final = mix(final, final_highlight_color, normal_diff);	}
	if (shadows_enabled) {
		final = mix(final, final_shadow_color, depth_diff);
	}
	
	// B&W
	if (bw_enabled) {
		vec3 accent_target = vec3(1.0, 0.0, 0.0);
		
		float red_intensity = original_color.r - max(original_color.g, original_color.b);
		
		bool is_accent = red_intensity > 0.05; 

		if (!is_accent) {
			float gray = dot(final, vec3(0.299, 0.587, 0.114));
			gray = (gray - 0.5) * contrast + 0.5 + (brightness - 1.0);
	        
			vec3 blue_tint = vec3(0.9, 0.95, 1.3);
			final = vec3(gray) * blue_tint;
		} else {
			final = original_color * 1.0; 
	    }
	}
	
	// RAIN
	if (rain_enabled) {
		vec2 uv = UV;
		uv.y += TIME * rain_speed * 0.05;
		
		vec2 grid_uv = uv * vec2(rain_spacing * 2.0, rain_spacing);
		vec2 grid_id = floor(grid_uv);
		vec2 grid_pos = fract(grid_uv);
		
		float rand = random(grid_id);
		float rain = 0.0;
		
		if (rand > 0.85) {
			float x_dist = abs(grid_pos.x - 0.5);
			float y_pos = grid_pos.y;
			float streak = smoothstep(streak_length, 0.0, y_pos);
			
			if (x_dist < streak_width) {
				rain = (1.0 - x_dist / streak_width) * streak;
			}
		}
		
		// Add white rain on top
		final = mix(final, vec3(1.0), rain * drop_brightness);
	}
	
	ALBEDO = final;
	ALPHA = 1.0;
}