shader_type spatial;
render_mode cull_back, depth_draw_always;

uniform sampler2D building_texture : source_color;
global uniform vec3 player_position;
global uniform float occlusion_amount; 

uniform float center_hole_radius = 0.5; 
uniform float dither_fade_length = 0.4; 
uniform float vertical_offset = 0.15; 

uniform float hole_opacity : hint_range(0.0, 1.0) = 0.05;

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
    float calculation_mask = 1.0;
    
    if (occlusion_amount > 0.001) {
        vec3 target_pos = player_position + vec3(0.0, vertical_offset, 0.0);
        vec3 cam_pos = CAMERA_POSITION_WORLD;
        vec3 view_dir = normalize(target_pos - cam_pos);
        
        float total_radius = center_hole_radius + dither_fade_length;
        
        vec3 segment_end = target_pos - (view_dir * total_radius);
        
        vec3 cam_to_end = segment_end - cam_pos;
        vec3 cam_to_pixel = world_pos - cam_pos;
        
        float t = dot(cam_to_pixel, cam_to_end) / dot(cam_to_end, cam_to_end);
        t = clamp(t, 0.0, 1.0);
        
        vec3 closest_point = cam_pos + t * cam_to_end;
        float dist_to_segment = length(world_pos - closest_point);
        
        float hole = smoothstep(center_hole_radius, total_radius, dist_to_segment);
        
        calculation_mask = mix(1.0, hole, occlusion_amount);
    }

    float final_alpha = mix(hole_opacity, 1.0, calculation_mask);
    final_alpha = clamp(final_alpha, 0.0, 1.0);

    vec4 tex = texture(building_texture, v_uv);
    ALBEDO = tex.rgb;
    
    float light = clamp(dot(NORMAL, vec3(0.3, 1.0, 0.3)), 0.6, 1.0);
    ALBEDO *= light;

    if (final_alpha < 0.99) {
        if (!dither_screenmask(SCREEN_UV, final_alpha, VIEWPORT_SIZE)) {
            discard;
        }
    }
}