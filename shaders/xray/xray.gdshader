shader_type spatial;
render_mode cull_back, depth_draw_always;

uniform sampler2D building_texture : source_color;
global uniform vec3 player_position;
global uniform float occlusion_amount; 

uniform float center_hole_radius = 0.2; 
uniform float dither_fade_length = 0.4; 
uniform float vertical_offset = 0.15; 
uniform float floor_height = 0.0; 

varying vec3 world_pos;
varying vec2 v_uv;

bool dither_screenmask(vec2 uv, float alpha, vec2 viewport_size) {
    float DITHER_THRESHOLDS[16] = float[](
        1.0/17.0, 9.0/17.0, 3.0/17.0, 11.0/17.0,
        13.0/17.0, 5.0/17.0, 15.0/17.0, 7.0/17.0,
        4.0/17.0, 12.0/17.0, 2.0/17.0, 10.0/17.0,
        16.0/17.0, 8.0/17.0, 14.0/17.0, 6.0/17.0
    );
    uint x = uint(uv.x * viewport_size.x) % 4u;
    uint y = uint(uv.y * viewport_size.y) % 4u;
    uint index = x * 4u + y;
    return alpha >= DITHER_THRESHOLDS[index];
}

void vertex() {
    v_uv = UV;
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
    float final_mask = 1.0;
    
    if (occlusion_amount > 0.001) {
        vec3 target_pos = player_position + vec3(0.0, vertical_offset, 0.0);
        vec3 view_dir = normalize(target_pos - CAMERA_POSITION_WORLD);
        vec3 rel_pos = world_pos - target_pos;
        float projection = dot(rel_pos, view_dir);
        
        // xray hole
        vec3 closest_point = projection * view_dir;
        float dist_to_line = length(rel_pos - closest_point);
        
        // fade out
        float hole = smoothstep(center_hole_radius, center_hole_radius + dither_fade_length, dist_to_line);
        
        // ground protector
        float true_ground = 1.0 - smoothstep(floor_height, floor_height + 0.1, world_pos.y);
        float safe_hole = mix(hole, 1.0, true_ground);
        
        final_mask = mix(1.0, safe_hole, occlusion_amount);
    }

    float final_alpha = clamp(final_mask, 0.0, 1.0);

    vec4 tex = texture(building_texture, v_uv);
    ALBEDO = tex.rgb;
    
    float light = clamp(dot(NORMAL, vec3(0.3, 1.0, 0.3)), 0.6, 1.0);
    ALBEDO *= light;

    if (final_alpha < 0.95) {
        if (!dither_screenmask(SCREEN_UV, final_alpha, VIEWPORT_SIZE)) {
            discard;
        }
    }
}