#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;

void main() {
    // 1. Use texture2DRect or standard texture2D with mediump if supported
    vec3 Color = texture2D(colortex0, texcoord).rgb;

    // 2. Pre-defined constants for Wynncraft's vibrant look
    // By inlining the math for saturation and contrast, we save the overhead of
    // jumping to another file/function.

    // Optimized Saturation (Inlined)
    float luma = dot(Color, vec3(0.2126, 0.7152, 0.0722));
    Color = mix(vec3(luma), Color, SATURATION);

    // Optimized Contrast (Inlined)
    // Using a centered mid-point (0.5) is faster for the GPU to process
    Color = (Color - 0.5) * CONTRAST + 0.5;

    // 3. Combined MinBright and Clamp
    // Pre-calculating the vec3 constant outside of the loop/main is better,
    // but here we ensure it's a single instruction.
    const vec3 MinBright = vec3(TONEMAP_MIN_R, TONEMAP_MIN_G, TONEMAP_MIN_B);
    Color = max(Color, MinBright);

    // 4. Final output - ensuring alpha is 1.0 to prevent transparency bugs
    gl_FragData[0] = vec4(Color, 1.0);
}
