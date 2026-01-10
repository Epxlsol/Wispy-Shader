#include "/lib/all_the_libs.glsl"

#include "/global/lighting.vsh"

// Fast triangle wave (3-4x faster than sin)
float tri_wave(float x) {
    x = fract(x);
    return abs(x + x - 1.0) - 0.5;
}

void main() {
    init_generic();

    #ifdef WAVY_PLANTS
    // Only process if close enough and is a wavy material
    if (ViewPos.z > -64.0 && material >= 10003.0) {
        vec3 WorldPos = to_player_pos(ViewPos) + cameraPosition;

        // Single noise calculation using dot product
        vec3 WavePos = WorldPos * (1.0 / WAVE_SIZE) + frameTimeCounter * WAVE_SPEED;
        float Noise = tri_wave(WavePos.x) * tri_wave(WavePos.y) * tri_wave(WavePos.z);
        Noise *= (WAVE_AMPLITUDE + rainStrength * 0.1);

        // Branch-free material selection
        bool isLeaf = (material == 10003.0);
        bool isPlant = (material == 10004.0);
        bool isPlantLower = (material == 10005.0);
        bool isPlantUpper = (material == 10006.0);

        #ifdef WAVE_LEAVES
        if (isLeaf) {
            WorldPos.x += Noise * 0.5;
            WorldPos.yz -= Noise * 0.5;
        }
        #endif

        if (isPlant || isPlantLower || isPlantUpper) {
            float topMult = float(gl_MultiTexCoord0.t < mc_midTexCoord.t);
            float bottomMult = float(gl_MultiTexCoord0.t > mc_midTexCoord.t);

            // Efficient multiplier calculation
            float mult = mix(
                mix(0.5, 1.0, float(isPlantUpper) * bottomMult),
                1.0,
                float(isPlant) * topMult
            );

            WorldPos += Noise * mult;
        }

        WorldPos -= cameraPosition;
        WorldPos = mat3(gbufferModelView) * WorldPos;
        gl_Position = gl_ProjectionMatrix * vec4(WorldPos, 1.0);
    }
    #endif

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
