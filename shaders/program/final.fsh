#include "/lib/all_the_libs.glsl"

// The [0 1 2] comment allows OptiFine/Iris to recognize this as a toggle
#define CAS_SHARPENING 0 // [0 1 2]

varying vec2 texcoord;

// Simple but effective sharpening function
vec3 apply_sharpening(vec3 col, float strength) {
    vec3 up    = texture2D(colortex0, texcoord + vec2(0.0, 1.0/viewHeight)).rgb;
    vec3 down  = texture2D(colortex0, texcoord - vec2(0.0, 1.0/viewHeight)).rgb;
    vec3 left  = texture2D(colortex0, texcoord - vec2(1.0/viewWidth, 0.0)).rgb;
    vec3 right = texture2D(colortex0, texcoord + vec2(1.0/viewWidth, 0.0)).rgb;
    
    vec3 edge = 4.0 * col - up - down - left - right;
    return col + edge * strength;
}

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    
    // --- Sharpening Pass ---
    #if CAS_SHARPENING == 1
        Color.rgb = apply_sharpening(Color.rgb, 0.2); // Subtle
    #elif CAS_SHARPENING == 2
        Color.rgb = apply_sharpening(Color.rgb, 0.4); // Strong
    #endif
    
    // --- Fast color adjustments ---
    Color.rgb = apply_saturation(Color.rgb, SATURATION);
    Color.rgb = apply_contrast(Color.rgb, CONTRAST);
    
    vec3 MinBright = vec3(TONEMAP_MIN_R, TONEMAP_MIN_G, TONEMAP_MIN_B);
    Color.rgb = max(Color.rgb, MinBright);
    
    gl_FragData[0] = Color;
}
