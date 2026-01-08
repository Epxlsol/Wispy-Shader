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
    LightmapCoords = max(LightmapCoords * 1.06667 - 0.0625, 0);
    material = mc_Entity.x;

    ViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;

    Normal = normalize(gl_NormalMatrix * gl_Normal);
    vec3 NormalA;
    if (material == 10001 || material == 10004 || material == 10005 || material == 10006) {
        NormalA = gbufferModelView[1].xyz;
        if (gl_MultiTexCoord0.t > mc_midTexCoord.t && (material == 10004 || material == 10005)) NormalA *= 0.5;
    }
    else {
        NormalA = Normal;
    }
    glcolor = gl_Color;

    #ifdef HANDHELD_LIGHTS
    float Dist = length(ViewPos);
    float HandheldLight = heldBlockLightValue;
    // Fast approximation: x^4 ≈ x*x*x*x (avoid pow)
    float hl = max((HandheldLight - Dist) / 15.0, 0);
    hl = hl * hl; // squared
    hl = hl * hl; // to the 4th
    LightmapCoords.x = max(LightmapCoords.x, hl);
    #endif

    // Torch color - fast gamma
    vec3 TorchColor = vec3(f_LM_RED, f_LM_GREEN, f_LM_BLUE);
    TorchColor *= TorchColor;
    
    float MinLight = clamp(MIN_LIGHT_AMOUNT + screenBrightness * 0.1 - 0.1, 0, 0.5);
    MinLight *= MinLight; // fast gamma
    MinLight += nightVision / 3;

    #ifndef DIMENSION_OVERWORLD
    LightmapCoords.y = 1;
    #endif

    #ifndef DIMENSION_NETHER
        #ifdef DIMENSION_END
            float NdotL = max(dot(NormalA, gbufferModelView[1].xyz), 0);
        #else
            float NdotL = max(dot(NormalA, sunOrMoonPosN), 0);
            float NdotU = clamp(dot(gbufferModelView[1].xyz, Normal), -1, 1);
            vec3 SkyGround = SKY_GROUND;
            SUN_AMBIENT = mix(SUN_AMBIENT, mix(SkyGround, SKY_TOP, NdotU * 0.25 + 0.25), 0.5);
        #endif

        float FakeShadowFactor = smoothstep(0.85, 0.96, LightmapCoords.y);
        SUN_AMBIENT += SUN_DIRECT * NdotL * FakeShadowFactor;
    #endif

    // Fast pow approximation: x^4
    float lmx = LightmapCoords.x;
    lmx = lmx * lmx; // squared
    lmx = lmx * lmx; // to the 4th
    LightmapCoords.x = lmx;

    LightmapCoords.x = mix(LightmapCoords.x, LightmapCoords.x, LightmapCoords.y);
    MixedLights = TorchColor * LightmapCoords.x + mix(vec3(MinLight), SUN_AMBIENT, LightmapCoords.y);
    MixedLights *= 1 - darknessLightFactor;
}
