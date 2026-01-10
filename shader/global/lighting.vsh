// Optimized lighting vertex shader

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
    LightmapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    LightmapCoords = clamp(LightmapCoords * 1.06667 - 0.0625, 0.0, 1.0);
    material = mc_Entity.x;

    ViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    Normal = normalize(gl_NormalMatrix * gl_Normal);
    vec3 NormalA;

    // Optimized material checks - branch-free
    float isSpecial = step(10000.5, material);
    float needsHalf = step(10003.5, material) * step(material, 10005.5);
    float halfMult = mix(1.0, 0.5, needsHalf * step(mc_midTexCoord.t, gl_MultiTexCoord0.t));
    
    NormalA = mix(Normal, gbufferModelView[1].xyz * halfMult, isSpecial);

    glcolor = gl_Color;

    #ifdef HANDHELD_LIGHTS
    float Dist = length(ViewPos);
    float HandheldLight = heldBlockLightValue;
    float hl = clamp((HandheldLight - Dist) * 0.06667, 0.0, 1.0); // 1/15
    // Optimized pow4
    hl = hl * hl;
    hl = hl * hl;
    LightmapCoords.x = max(LightmapCoords.x, hl);
    #endif

    // Torch color (fast gamma)
    vec3 TorchColor = vec3(f_LM_RED, f_LM_GREEN, f_LM_BLUE);
    TorchColor *= TorchColor;

    float MinLight = clamp(MIN_LIGHT_AMOUNT + screenBrightness * 0.1 - 0.1, 0.0, 0.5);
    MinLight = MinLight * MinLight + nightVision * 0.333;

    #ifndef DIMENSION_OVERWORLD
    LightmapCoords.y = 1.0;
    #endif

    // Optimized lighting calculation
    #ifndef DIMENSION_NETHER
    #ifdef DIMENSION_END
    float NdotL = max(dot(NormalA, gbufferModelView[1].xyz), 0.0);
    #else
    float NdotL = max(dot(NormalA, sunOrMoonPosN), 0.0);
    float NdotU = clamp(dot(gbufferModelView[1].xyz, Normal), -1.0, 1.0);
    vec3 SkyGround = SKY_GROUND;
    SUN_AMBIENT = mix(SUN_AMBIENT, mix(SkyGround, SKY_TOP, NdotU * 0.25 + 0.25), 0.5);
    #endif

    float FakeShadowFactor = smoothstep(0.85, 0.96, LightmapCoords.y);
    SUN_AMBIENT += SUN_DIRECT * NdotL * FakeShadowFactor;
    #endif

    // Optimized pow4 for lightmap
    float lm2 = LightmapCoords.x * LightmapCoords.x;
    LightmapCoords.x = lm2 * lm2;

    // Combined lighting calculation
    MixedLights = TorchColor * LightmapCoords.x + mix(vec3(MinLight), SUN_AMBIENT, LightmapCoords.y);
    MixedLights *= 1.0 - darknessLightFactor;
}
