#include "/lib/all_the_libs.glsl"

// We are going to bypass the heavy init_generic() and do a "light" version
varying vec2 LightmapCoords;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

#include "/global/light_colors.vsh"

void main() {
    // 1. Basic Position and Texcoords (Fastest possible)
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    // 2. Simplified Lightmap (No complex clamping/offsetting for entities)
    LightmapCoords = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

    // 3. Fast Lighting for Entities
    // Mobs and Players don't need complex "Fake Shadows" or NdotL logic
    // We just give them basic ambient + torch light.
    init_colors(); // Get the current sun/sky colors

    float lmx = LightmapCoords.x * LightmapCoords.x; // Quick gamma for torch
    vec3 TorchPart = vec3(f_LM_RED, f_LM_GREEN, f_LM_BLUE) * lmx;

    // Simple blend of Sky and Sun for entities
    vec3 Ambient = mix(SKY_GROUND, SUN_AMBIENT, LightmapCoords.y);

    MixedLights = (TorchPart + Ambient) * (1.0 - darknessLightFactor);
    glcolor = gl_Color;

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
