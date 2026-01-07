#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;

void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    
    // Fast color adjustments
    Color.rgb = apply_saturation(Color.rgb, SATURATION);
    Color.rgb = apply_contrast(Color.rgb, CONTRAST);
    
    vec3 MinBright = vec3(TONEMAP_MIN_R, TONEMAP_MIN_G, TONEMAP_MIN_B);
    Color.rgb = max(Color.rgb, MinBright);
    
    gl_FragData[0] = Color;
}
