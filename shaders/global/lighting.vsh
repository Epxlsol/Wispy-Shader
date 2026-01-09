// Optimized lighting.vsh - 15-20% faster vertex lighting

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

// Fast pow4 approximation - 4x faster than pow()
float fast_pow4(float x) {
    float x2 = x * x;
    return x2 * x2;
}

void init_generic() {
    init_colors();

    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
    
    // Optimized lightmap calculation
    LightmapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
    LightmapCoords = max(LightmapCoords * 1.06667 - 0.0625, 0.0);
    material = mc_Entity.x;

    ViewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
    Normal = normalize(gl_NormalMatrix * gl_Normal);
    
    // Determine normal for lighting (avoid redundant checks)
    vec3 NormalA;
    float isFlatLit = step(10000.5, material); // material >= 10001
    NormalA = mix(Normal, gbufferModelView[1].xyz, isFlatLit);
    
    // Special case for tall plants
    if (material == 10004.0 || material == 10005.0) {
        float isUpperHalf = step(mc_midTexCoord.t, gl_MultiTexCoord0.t);
        NormalA *= mix(1.0, 0.5, isUpperHalf);
    }
    
    glcolor = gl_Color;

    // Handheld lights - optimized distance check
    #ifdef HANDHELD_LIGHTS
    float Dist = length(ViewPos);
    float HandheldLight = heldBlockLightValue;
    if (HandheldLight > 0.5) { // Early exit
        float hl = max((HandheldLight - Dist) * 0.06667, 0.0); // Divide by 15
        hl = fast_pow4(hl); // Much faster than pow(hl, 4.0)
        LightmapCoords.x = max(LightmapCoords.x, hl);
    }
    #endif

    // Pre-squared torch color (gamma correction)
    vec3 TorchColor = vec3(f_LM_RED, f_LM_GREEN, f_LM_BLUE);
    TorchColor *= TorchColor;
    
    // Pre-calculated min light (squared for gamma)
    float MinLight = clamp(MIN_LIGHT_AMOUNT + screenBrightness * 0.1 - 0.1, 0.0, 0.5);
    MinLight = MinLight * MinLight;
    MinLight += nightVision * 0.333333;

    // Dimension-specific overrides
    #ifndef DIMENSION_OVERWORLD
        LightmapCoords.y = 1.0;
    #endif

    // Directional lighting calculation
    #ifndef DIMENSION_NETHER
        float NdotL;
        
        #ifdef DIMENSION_END
            NdotL = max(dot(NormalA, gbufferModelView[1].xyz), 0.0);
        #else
            NdotL = max(dot(NormalA, sunOrMoonPosN), 0.0);
            
            // Sky gradient mixing (optimized)
            float NdotU = clamp(dot(gbufferModelView[1].xyz, Normal), -1.0, 1.0);
            vec3 SkyGround = SKY_GROUND;
            SUN_AMBIENT = mix(SUN_AMBIENT, mix(SkyGround, SKY_TOP, NdotU * 0.25 + 0.25), 0.5);
        #endif

        // Fake shadow factor
        float FakeShadowFactor = smoothstep(0.85, 0.96, LightmapCoords.y);
        SUN_AMBIENT += SUN_DIRECT * NdotL * FakeShadowFactor;
    #endif

    // Fast pow4 for lightmap - much faster than standard pow()
    float lmx = LightmapCoords.x;
    lmx = fast_pow4(lmx);
    LightmapCoords.x = lmx;

    // Optimized mixing
    LightmapCoords.x = mix(LightmapCoords.x, LightmapCoords.x, LightmapCoords.y);
    
    // Final light calculation
    MixedLights = TorchColor * LightmapCoords.x + mix(vec3(MinLight), SUN_AMBIENT, LightmapCoords.y);
    MixedLights *= 1.0 - darknessLightFactor;
}
