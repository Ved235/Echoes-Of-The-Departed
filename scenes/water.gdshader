shader_type spatial;
render_mode blend_mix, depth_draw_opaque; // Removed "unshaded" to receive lighting

// Almost black-blue color with high opacity for an eerie look
uniform vec4 water_color = vec4(0.01, 0.02, 0.05, 0.95); // Made even darker
uniform vec4 deep_water_color = vec4(0.005, 0.015, 0.03, 0.98); // Even darker for depth
uniform float wave_amplitude = 0.15; // Slightly reduced amplitude for calmer water
uniform float wave_frequency = 3.0; // Reduced frequency for longer waves
uniform float wave_speed = 1.0; // Slower speed for a more ominous feel

// Lighting controls
uniform float ambient_occlusion = 0.8; // Controls darkness level
uniform float metallic = 0.1; // Low metallic for murky water
uniform float roughness = 0.85; // High roughness for dark water

void vertex() {
    // Create subtle, slow-moving waves
    float wave = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * 
                 cos(VERTEX.z * wave_frequency * 0.5 + TIME * wave_speed * 0.8) * 
                 wave_amplitude;
    VERTEX.y += wave;
    
    // Update normals for better lighting
    NORMAL = normalize(vec3(
        -cos(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_amplitude * 0.5,
        1.0,
        -cos(VERTEX.z * wave_frequency * 0.5 + TIME * wave_speed * 0.8) * wave_amplitude * 0.5
    ));
}

void fragment() {
    // Add subtle depth variation
    float depth = (VERTEX.y + wave_amplitude) * 0.5 + 0.5;
    vec4 final_color = mix(deep_water_color, water_color, depth * 0.2);
    
    ALBEDO = final_color.rgb;
    ALPHA = final_color.a;
    
    // Set surface properties for shadowed appearance
    METALLIC = metallic;
    ROUGHNESS = roughness;
    AO = ambient_occlusion; // Apply ambient occlusion to darken
    
    // Reduce specular reflection
    SPECULAR = 0.1;
}