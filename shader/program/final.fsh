#include "/lib/all_the_libs.glsl"
varying vec2 texcoord;

vec3 applyColorGrading(vec3 color) {
    float temp = COLOR_TEMPERATURE;
    color.r += temp * 0.15;
    color.b -= temp * 0.15;
    float tint = COLOR_TINT;
    color.g += tint * 0.1;
    color.r -= tint * 0.05;
    color.b -= tint * 0.05;
    return color;
}

vec3 applySplitTone(vec3 color) {
    float lum = get_luminance(color);
    float shadowMask = 1.0 - smoothstep(0.0, 0.3, lum);
    float highlightMask = smoothstep(0.6, 1.0, lum);
    color *= mix(1.0, SHADOW_CONTRAST, shadowMask * 0.5);
    color *= mix(1.0, HIGHLIGHT_CONTRAST, highlightMask * 0.5);
    return color;
}

void main() {
    vec2 distortedTC = texcoord;
    #ifdef UNDERWATER_DISTORTION
    if (isEyeInWater == 1) {
        vec2 offset = vec2(
            sin(texcoord.y * 10.0 + frameTimeCounter * 2.0),
                           cos(texcoord.x * 10.0 + frameTimeCounter * 2.0)
        ) * DISTORTION_STRENGTH;
        distortedTC += offset;
    }
    #endif

    #ifdef LAVA_DISTORTION
    if (isEyeInWater == 2) {
        vec2 offset = vec2(
            sin(texcoord.y * 20.0 + frameTimeCounter * 4.0),
                           cos(texcoord.x * 20.0 - frameTimeCounter * 4.0)
        ) * LAVA_DISTORTION_STRENGTH;
        distortedTC += offset;
    }
    #endif

    #ifdef NETHER_HEAT_DISTORTION
    #ifdef DIMENSION_NETHER
    vec2 heatWave = vec2(
        sin(texcoord.y * 15.0 + frameTimeCounter * 3.0),
                         cos(texcoord.x * 15.0 + frameTimeCounter * 2.0)
    ) * NETHER_DISTORTION_STRENGTH;
    distortedTC += heatWave;
    #endif
    #endif

    vec4 Color = texture2D(colortex0, distortedTC);
    float depth = texture2D(depthtex0, texcoord).r;

    #ifdef NIGHT_VISION_TINT
    if (nightVision > 0.01) {
        vec3 nvTint = vec3(NIGHT_VISION_R, NIGHT_VISION_G, NIGHT_VISION_B);
        Color.rgb = mix(Color.rgb, Color.rgb * nvTint, nightVision * 0.5);
    }
    #endif

    #ifdef FROST_EFFECT
    if (temperature < 0.15 && isEyeInWater == 0) {
        vec3 frostColor = vec3(0.7, 0.85, 1.0);
        float frostMask = (0.15 - temperature) * 6.67;
        Color.rgb = mix(Color.rgb, Color.rgb * frostColor, frostMask * FROST_STRENGTH);
    }
    #endif

    #ifdef END_VOID_FOG
    #ifdef DIMENSION_END
    if (depth >= 0.9999) {
        vec3 voidColor = vec3(0.1, 0.0, 0.15);
        float voidFog = 1.0 - exp(-length(texcoord - 0.5) * END_FOG_DENSITY);
        Color.rgb = mix(Color.rgb, voidColor, voidFog);
    }
    #endif
    #endif

    #ifdef NETHER_AMBIENT_PULSE
    #ifdef DIMENSION_NETHER
    float pulse = sin(frameTimeCounter * NETHER_PULSE_SPEED) * 0.5 + 0.5;
    Color.rgb += vec3(0.1, 0.0, 0.0) * pulse * NETHER_PULSE_STRENGTH;
    #endif
    #endif

    // --- REWRITTEN VIGNETTE SECTION ---
    vec2 uv = texcoord - 0.5;
    #ifdef VIGNETTE
    // Using smoothstep and length prevents the "ring" look and creates a soft corner fade
    float vFactor = smoothstep(0.8, 0.1, length(uv) * VIGNETTE_STRENGTH);
    Color.rgb *= vFactor;
    #endif

    #ifdef HURT_VIGNETTE
    // Kept this math separate so the red damage pulse still works as intended
    float vignetteBase = 1.0 - dot(uv * 2.0, uv * 2.0);
    float hurtAmount = darknessLightFactor * 0.5 + max(0.0, 1.0 - eyeBrightnessSmooth.x / 240.0) * 0.3;
    if (hurtAmount > 0.01) {
        float hurtVig = pow(max(0.0, vignetteBase), 2.0) * hurtAmount * HURT_VIGNETTE_STRENGTH;
        Color.rgb = mix(Color.rgb, vec3(1.0, 0.0, 0.0), hurtVig);
    }
    #endif
    // ----------------------------------

    #ifdef EDGE_DARKENING
    if (depth < 0.9999) {
        vec2 edge = abs(texcoord - 0.5) * 2.0;
        float edgeFactor = smoothstep(0.7, 1.0, max(edge.x, edge.y));
        Color.rgb *= 1.0 - edgeFactor * EDGE_STRENGTH;
    }
    #endif

    Color.rgb = applyColorGrading(Color.rgb);
    Color.rgb = applySplitTone(Color.rgb);
    Color.rgb = apply_saturation(Color.rgb, SATURATION);
    Color.rgb = apply_vibrance(Color.rgb, VIBRANCE);
    Color.rgb = apply_contrast(Color.rgb, CONTRAST);

    vec3 MinBright = vec3(TONEMAP_MIN_R, TONEMAP_MIN_G, TONEMAP_MIN_B);
    Color.rgb = max(Color.rgb, MinBright);

    gl_FragColor = vec4(Color.rgb, Color.a);
}
