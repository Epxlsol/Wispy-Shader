#include "/lib/all_the_libs.glsl"
#ifdef CEL_SHADING
#include "/global/post/cel_shading.glsl"
#endif
varying vec2 texcoord;
vec3 performUpscalingAndSharpening(sampler2D tex, vec2 uv, float scale) {
    vec2 scaledResolution = resolution * scale;
    vec2 invScaledResolution = vec2(1.0) / scaledResolution;
    vec2 pos = uv * scaledResolution;
    vec2 fp = fract(pos);
    vec2 tc = (floor(pos) + 0.5) * invScaledResolution;
    vec3 c0 = texture2D(tex, tc).rgb;
    vec3 c1 = texture2D(tex, tc + vec2(invScaledResolution.x, 0.0)).rgb;
    vec3 c2 = texture2D(tex, tc + vec2(0.0, invScaledResolution.y)).rgb;
    vec3 c3 = texture2D(tex, tc + invScaledResolution).rgb;
    float w0 = (1.0 - fp.x) * (1.0 - fp.y);
    float w1 = fp.x * (1.0 - fp.y);
    float w2 = (1.0 - fp.x) * fp.y;
    float w3 = fp.x * fp.y;
    vec3 result = c0 * w0 + c1 * w1 + c2 * w2 + c3 * w3;
    vec3 delta03 = c0 - c3;
    vec3 delta12 = c1 - c2;
    float edgeSquared03 = dot(delta03, delta03);
    float edgeSquared12 = dot(delta12, delta12);
    float edgeMetric = sqrt(edgeSquared03) + sqrt(edgeSquared12);
    float edgeFactor = clamp(edgeMetric * 2.0, 0.0, 1.0);
    float baseSharpness = FSR_SHARPNESS * 0.5;
    float adaptiveSharpness = baseSharpness + (FSR_SHARPNESS - baseSharpness) * edgeFactor;
    if (adaptiveSharpness > 0.01) {
        vec3 minCorner = min(min(c0, c1), min(c2, c3));
        vec3 maxCorner = max(max(c0, c1), max(c2, c3));
        vec3 avg = (c0 + c1 + c2 + c3) * 0.25;
        float aggressiveFactor = adaptiveSharpness * adaptiveSharpness;
        vec3 sharpened = result + (result - avg) * aggressiveFactor * 2.0;
        return clamp(sharpened, minCorner, maxCorner);
    }
    return result;
}
float getFSRScale() {
    #if FSR_QUALITY == 1
    return 0.77;
    #elif FSR_QUALITY == 2
    return 0.67;
    #elif FSR_QUALITY == 3
    return 0.59;
    #elif FSR_QUALITY == 4
    return 0.50;
    #else
    return 1.0;
    #endif
}
vec3 applyColorGrading(vec3 color) {
    const float base_temp_r = 0.15;
    const float base_temp_b = 0.15;
    const float base_tint_g = 0.1;
    const float base_tint_rb = 0.05;
    float temp = COLOR_TEMPERATURE;
    color.r += temp * base_temp_r;
    color.b -= temp * base_temp_b;
    float tint = COLOR_TINT;
    color.g += tint * base_tint_g;
    color.r -= tint * base_tint_rb;
    color.b -= tint * base_tint_rb;
    return color;
}
vec3 applySplitTone(vec3 color) {
    const float shadow_threshold = 0.3;
    const float highlight_threshold = 0.6;
    const float shadow_strength = 0.5;
    const float highlight_strength = 0.5;
    float lum = get_luminance(color);
    float shadowMask = 1.0 - smoothstep(0.0, shadow_threshold, lum);
    float highlightMask = smoothstep(highlight_threshold, 1.0, lum);
    color *= mix(1.0, SHADOW_CONTRAST, shadowMask * shadow_strength);
    color *= mix(1.0, HIGHLIGHT_CONTRAST, highlightMask * highlight_strength);
    return color;
}
void main() {
    vec2 distortedTC = texcoord;
    #if defined(UNDERWATER_DISTORTION) || defined(LAVA_DISTORTION) || defined(NETHER_HEAT_DISTORTION)
    if (isEyeInWater == 1) {
        #ifdef UNDERWATER_DISTORTION
        vec2 offset = vec2(
            sin(texcoord.y * 10.0 + frameTimeCounter * 2.0),
                           cos(texcoord.x * 10.0 + frameTimeCounter * 2.0)
        ) * DISTORTION_STRENGTH;
        distortedTC += offset;
        #endif
    }
    else if (isEyeInWater == 2) {
        #ifdef LAVA_DISTORTION
        vec2 offset = vec2(
            sin(texcoord.y * 20.0 + frameTimeCounter * 4.0),
                           cos(texcoord.x * 20.0 - frameTimeCounter * 4.0)
        ) * LAVA_DISTORTION_STRENGTH;
        distortedTC += offset;
        #endif
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
    #ifdef FSR_UPSCALING
    float scale = getFSRScale();
    vec4 Color = vec4(performUpscalingAndSharpening(colortex0, distortedTC, scale), 1.0);
    #else
    vec4 Color = texture2D(colortex0, distortedTC);
    #endif
    float depth = texture2D(depthtex0, texcoord).r;
    #ifdef FROST_EFFECT
    if (temperature < 0.2 && isEyeInWater == 0) {
        vec3 frostColor = vec3(0.7, 0.85, 1.0);
        float frostLevel = clamp((0.2 - temperature) * 5.0, 0.0, 1.0);
        float slowPulse = sin(frameTimeCounter * 0.2) * 0.05 + 0.95;
        float frostMask = smoothstep(0.0, 1.0, frostLevel * slowPulse);
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
    vec2 uv = texcoord - 0.5;
    #ifdef VIGNETTE
    float vFactor = smoothstep(0.8, 0.1, length(uv) * VIGNETTE_STRENGTH);
    Color.rgb *= vFactor;
    #endif
    #ifdef CEL_SHADING
    Color.rgb = applyCelShading(Color.rgb, texcoord);
    #endif
    Color.rgb = applyColorGrading(Color.rgb);
    Color.rgb = applySplitTone(Color.rgb);
    Color.rgb = apply_saturation(Color.rgb, SATURATION);
    Color.rgb = apply_vibrance(Color.rgb, VIBRANCE);
    Color.rgb = apply_contrast(Color.rgb, CONTRAST);
    vec3 MinBright = vec3(TONEMAP_MIN_R, TONEMAP_MIN_G, TONEMAP_MIN_B);
    Color.rgb = max(Color.rgb, MinBright);
    ivec2 finalFragCoord = ivec2(gl_FragCoord.xy);
    #if DEBUG_SHOW_BUFFER == 0
    gl_FragColor = vec4(Color.rgb, 1.0);
    #elif DEBUG_SHOW_BUFFER == 1
    gl_FragColor = texelFetch2D(colortex1, finalFragCoord, 0);
    #elif DEBUG_SHOW_BUFFER == 2
    gl_FragColor = texelFetch2D(noisetex, finalFragCoord, 0);
    #elif DEBUG_SHOW_BUFFER == 3
    gl_FragColor = texelFetch2D(depthtex0, finalFragCoord, 0);
    #else
    gl_FragColor = texelFetch2D(gaux1, finalFragCoord, 0);
    #endif
}
