#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;

void main() {
    // 1. Get color and alpha from the previous pass
    vec4 Color = texture2D(colortex0, texcoord);

    // 2. Vignette logic
    #ifdef VIGNETTE
    vec2 uv = texcoord * 2.0 - 1.0;
    float vFactor = clamp(1.0 - dot(uv, uv) * VIGNETTE_STRENGTH, 0.0, 1.0);
    Color.rgb *= vFactor;
    #endif

    // 3. Edge darkening
    #ifdef EDGE_DARKENING
    float depth = texture2D(depthtex0, texcoord).r;
    if (depth < 0.9999) {
        vec2 edge = abs(texcoord - 0.5) * 2.0;
        float edgeFactor = smoothstep(0.7, 1.0, max(edge.x, edge.y));
        Color.rgb *= 1.0 - edgeFactor * EDGE_STRENGTH;
    }
    #endif

    // 4. Color adjustments
    Color.rgb = apply_saturation(Color.rgb, SATURATION);
    Color.rgb = apply_contrast(Color.rgb, CONTRAST);

    // 5. Tone Correction
    vec3 MinBright = vec3(TONEMAP_MIN_R, TONEMAP_MIN_G, TONEMAP_MIN_B);
    Color.rgb = max(Color.rgb, MinBright);

    // 6. Final output with transparency fix
    gl_FragColor = vec4(Color.rgb, Color.a);
}
