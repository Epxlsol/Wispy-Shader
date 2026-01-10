#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;
uniform mat4 gb_projection;
#include "/global/post/taa.glsl"

/* DRAWBUFFERS:0 */

// --- Motion Blur Logic ---
#ifdef MOTION_BLUR
vec3 motion_blur(vec3 Color, vec2 PrevCoord, vec2 CurrentCoord) {
    vec2 Velocity = PrevCoord - CurrentCoord;
    vec2 Offset = Velocity / 4.0 * MOTION_BLUR_STRENGTH;
    Offset *= 0.01666 / frameTime;
    vec3 Blur = Color;

    float Noise = bayer8(gl_FragCoord.xy);
    CurrentCoord += Offset * Noise;

    for (int i = 1; i < 4; i++) {
        Blur += texture2D(colortex0, CurrentCoord).rgb;
        CurrentCoord += Offset;
    }
    return Blur / 4.0;
}
#endif

void main() {
    vec4 Color = texture2D(colortex0, texcoord);

    #if TAA_MODE != 0 || defined MOTION_BLUR
    bool IsDH;
    float Depth = get_depth_solid(texcoord, IsDH);
    vec2 PrevCoord = toPrevScreenPos(texcoord, Depth, IsDH);
    #endif

    #ifdef MOTION_BLUR
    if (Depth >= 0.56) {
        Color.rgb = motion_blur(Color.rgb, PrevCoord, texcoord);
    }
    #endif

    // --- TAA Pass ---
    #if TAA_MODE != 0
    Color.rgb = TAA(Color.rgb, vec3(texcoord.xy, Depth), PrevCoord, IsDH);
    #endif

    // --- Color Grading & Tonemapping ---
    Color.rgb *= EXPOSURE;
    Color.rgb = apply_tonemap(Color.rgb);

    #if TONEMAP_OPERATOR != 3
    Color.rgb = pow(max(Color.rgb, vec3(0.0)), vec3(0.4545));
    #endif

    // --- Vignette (Slider Linked) ---
    // Runs whenever the slider is above 0.0 to ensure the menu works.
    if (VIGNETTE_FALLOFF > 0.01) {
        float dist = distance(texcoord, vec2(0.5));
        // Higher Falloff = darker, wider corners.
        float vignette = smoothstep(0.8, 0.5 - (VIGNETTE_FALLOFF * 0.4), dist);
        Color.rgb *= vignette;
    }

    // --- Film Grain ---
    #ifdef FILM_GRAIN
    float stableTime = mod(float(worldTime), 100.0) * 0.05;
    vec2 seed1 = texcoord + stableTime;
    vec2 seed2 = texcoord * 1.5 - stableTime;

    float n1 = fract(sin(dot(seed1, vec2(12.9898, 78.233))) * 43758.5453);
    float n2 = fract(sin(dot(seed2, vec2(26.1231, 45.129))) * 21532.1234);

    float finalNoise = (n1 + n2) * 2.5;

    Color.rgb += (finalNoise - 0.5) * (FILM_GRAIN_STRENGTH * 0.25);
    #endif

    gl_FragData[0] = vec4(Color.rgb, 1.0);
}
