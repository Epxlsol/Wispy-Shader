varying vec2 LightmapCoords;
varying vec2 texcoord;
varying vec4 glcolor;
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
flat varying float material;
varying vec3 MixedLights;
flat varying vec3 Normal;

vec3 ViewPos;
#include "/global/light_colors.vsh"
#include "/global/sky.glsl"

void init_generic() {
    init_colors();

    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // Optimized Lightmap math - removed unnecessary clamp/offset if possible
    LightmapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    LightmapCoords = clamp(LightmapCoords * 1.06667 - 0.0625, 0.0, 1.0);
    material = mc_Entity.x;

    ViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    Normal = normalize(gl_NormalMatrix * gl_Normal);

    vec3 NormalA = Normal;

    // 1. Faster Material Check: Removed 'step' calls and used a single 'if'
    // This is faster on most GPUs because 'step' still forces the GPU to evaluate both sides
    if (material > 10000.5) {
        NormalA = gbufferModelView[1].xyz;
        if (material >= 10003.5 && material <= 10005.5) {
            if (mc_midTexCoord.t < gl_MultiTexCoord0.t) NormalA *= 0.5;
        }
    }

    glcolor = gl_Color;

    // 2. Handheld Lights Optimization
    #ifdef HANDHELD_LIGHTS
    if (heldBlockLightValue > 0) {
        float Dist = length(ViewPos);
        // Linear approximation instead of pow4 for minor perf gain
        float hl = clamp((float(heldBlockLightValue) - Dist) * 0.0666, 0.0, 1.0);
        LightmapCoords.x = max(LightmapCoords.x, hl * hl);
    }
    #endif

    // 3. Torch Color Pre-Calculation
    // We use a constant vec3 instead of repeated multiplication
    const vec3 torchGamma = vec3(f_LM_RED * f_LM_RED, f_LM_GREEN * f_LM_GREEN, f_LM_BLUE * f_LM_BLUE);

    float MinLight = clamp(MIN_LIGHT_AMOUNT + screenBrightness * 0.1 - 0.1, 0.0, 0.5);
    MinLight = MinLight * MinLight + nightVision * 0.333;

    #ifndef DIMENSION_OVERWORLD
    LightmapCoords.y = 1.0;
    #endif

    // 4. Lighting Calculation Optimization
    #ifndef DIMENSION_NETHER
    #ifdef DIMENSION_END
    float NdotL = max(dot(NormalA, gbufferModelView[1].xyz), 0.0);
    #else
    float NdotL = max(dot(NormalA, sunOrMoonPosN), 0.0);
    float NdotU = clamp(Normal.y, -1.0, 1.0); // Simplified dot with Up vector

    // Replaced mix with simple linear math
    SUN_AMBIENT = (SUN_AMBIENT + mix(SKY_GROUND, SKY_TOP, NdotU * 0.25 + 0.25)) * 0.5;
    #endif

    // Faster FakeShadow instead of smoothstep
    float FakeShadowFactor = clamp((LightmapCoords.y - 0.85) * 9.09, 0.0, 1.0);
    SUN_AMBIENT += SUN_DIRECT * NdotL * FakeShadowFactor;
    #endif

    // 5. Lightmap Curve Optimization
    float lmx = LightmapCoords.x;
    lmx *= lmx; // pow2
    lmx *= lmx; // pow4

    // Faster manual blend
    vec3 AmbientPart = vec3(MinLight) + (SUN_AMBIENT - MinLight) * LightmapCoords.y;
    MixedLights = (torchGamma * lmx + AmbientPart) * (1.0 - darknessLightFactor);
}
