varying vec2 LightmapCoords;
varying vec2 texcoord;
varying vec4 glcolor;

attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;

flat varying float material;
varying mediump vec3 MixedLights;
flat varying vec3 Normal;

vec3 ViewPos;

#include "/global/light_colors.vsh"
#include "/global/sky.glsl"

void init_generic() {
    init_colors();

    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // STABILITY FIX: Add anti-flicker clamping to lightmap coordinates
    // Precompute constant to avoid repeated multiplication
    const float lightmapScale = 1.06667;
    const float lightmapOffset = 0.0625;
    LightmapCoords = clamp((gl_TextureMatrix[1] * gl_MultiTexCoord1).xy * lightmapScale - lightmapOffset, 0.001, 0.999);

    material = mc_Entity.x;
    ViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    glcolor = gl_Color;

    vec3 NormalA;

    if (material >= 10000.0) {
        NormalA = gbufferModelView[1].xyz;
        // Precompute step values to avoid repeated calculations
        float materialStep = step(10003.5, material);
        float materialStep2 = step(material, 10005.5);
        float needsHalf = materialStep * materialStep2;
        float midTexCoordStep = step(mc_midTexCoord.t, gl_MultiTexCoord0.t);
        NormalA *= mix(1.0, 0.5, needsHalf * midTexCoordStep);
    } else {
        Normal = normalize(gl_NormalMatrix * gl_Normal);
        NormalA = Normal;
    }

    // ===== ENHANCED HANDHELD LIGHT (FREE) =====
    #ifdef HANDHELD_LIGHTS
    float Dist = length(ViewPos);
    #ifdef DYNAMIC_HANDLIGHT
    // Precompute constant for falloff calculation
    const float halfDivisor = 0.5;
    // Smooth falloff curve
    float hl = pow(clamp(1.0 - Dist / (heldBlockLightValue * halfDivisor), 0.0, 1.0), HANDHELD_FALLOFF_CURVE);
    #else
    // Precompute divisor to avoid division
    const float inv_15 = 1.0 / 15.0;
    float hl = clamp((heldBlockLightValue - Dist) * inv_15, 0.0, 1.0);
    hl *= hl;
    #endif
    // STABILITY FIX: Smooth handheld light transitions
    LightmapCoords.x = max(LightmapCoords.x, clamp(hl, 0.0, 0.999));
    #endif

    // Precompute torch color squared
    vec3 TorchColor = vec3(f_LM_RED, f_LM_GREEN, f_LM_BLUE);
    TorchColor *= TorchColor;

    // Precompute constants for minimum light calculation
    const float screenBrightnessFactor = 0.1;
    const float nightVisionFactor = 0.333;
    float MinLight = clamp(MIN_LIGHT_AMOUNT + screenBrightness * screenBrightnessFactor - screenBrightnessFactor, 0.0, 0.5);
    MinLight = MinLight * MinLight + nightVision * nightVisionFactor;

    #ifndef DIMENSION_OVERWORLD
    LightmapCoords.y = 0.999; // STABILITY FIX: Avoid 1.0 edge cases
    #endif

    #ifndef DIMENSION_NETHER
    #ifdef DIMENSION_END
    float NdotL = max(dot(NormalA, gbufferModelView[1].xyz), 0.0);
    #else
    float NdotL = max(dot(NormalA, sunOrMoonPosN), 0.0);
    float NdotU = clamp(dot(gbufferModelView[1].xyz, NormalA), -1.0, 1.0);
    // Precompute constants for sky ambient calculation
    const float skyFactor = 0.25;
    SUN_AMBIENT = mix(SUN_AMBIENT, mix(SKY_GROUND, SKY_TOP, NdotU * skyFactor + skyFactor), 0.5);
    #endif

    // ===== STABILITY FIX: Anti-flicker shadow transitions =====
    #ifdef SOFTEN_SHADOWS
    // Precompute smoothstep constants
    const float shadowMin = 0.80;
    const float shadowMax = 0.99;
    // Wider transition range to prevent rapid switching
    float shadowTransition = smoothstep(shadowMin, shadowMax, LightmapCoords.y);  // Widened range
    #else
    const float shadowMin = 0.80;
    const float shadowMax = 0.99;
    float shadowTransition = smoothstep(shadowMin, shadowMax, LightmapCoords.y);  // Widened range
    #endif

    // STABILITY FIX: Prevent rapid flickering by smoothing the transition
    SUN_AMBIENT += SUN_DIRECT * NdotL * clamp(shadowTransition, 0.01, 0.99);
    #endif

    // Directional lightmap
    #ifdef DIRECTIONAL_LIGHTMAP
    // Precompute lightmap falloff
    float lmx = pow(LightmapCoords.x, LM_FALLOFF_CURVE);
    #else
    float lmx = LightmapCoords.x;
    // Use multiplication instead of pow for faster calculation
    lmx *= lmx;
    lmx *= lmx;
    #endif

    // STABILITY FIX: Prevent extreme lighting values
    MixedLights = TorchColor * lmx
    + mix(vec3(0.001), SUN_AMBIENT, clamp(LightmapCoords.y, 0.001, 0.999)); // Clamp to prevent edge artifacts

    // STABILITY FIX: Smooth darkness transitions
    // Precompute constant for darkness factor
    const float darknessOffset = 1.0;
    MixedLights *= clamp(darknessOffset - darknessLightFactor, 0.01, 1.0);
}
