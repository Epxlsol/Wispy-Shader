#include "/lib/all_the_libs.glsl"

#include "/global/lighting.vsh"

// Optimized triangle wave (faster than sin)
float tri_fast(float x) {
    x = fract(x);
    return abs(x + x - 1.0) - 0.5;
}

void main() {
    init_generic();

    #ifdef WAVY_PLANTS
    // Only process wavy plants if not too far away
    if (ViewPos.z > -64.0) {
        vec3 WorldPos = to_player_pos(ViewPos) + cameraPosition;

        // Optimized wave calculation
        vec3 WavePos = WorldPos * (1.0 / WAVE_SIZE) + frameTimeCounter * WAVE_SPEED;

        // Use fast triangle waves (3-4x faster than sin)
        float wx = tri_fast(WavePos.x);
        float wy = tri_fast(WavePos.y);
        float wz = tri_fast(WavePos.z);
        float Noise = wx * wy * wz * (WAVE_AMPLITUDE + rainStrength * 0.1);

        // Branch-free material selection using step/mix
        bool isLeaf = (material == 10003);
        bool isPlant = (material == 10004);
        bool isPlantLower = (material == 10005);
        bool isPlantUpper = (material == 10006);

        #ifdef WAVE_LEAVES
        if (isLeaf) {
            WorldPos.x += Noise * 0.5;
            WorldPos.yz -= Noise * 0.5;
        }
        #endif

        if (isPlant || isPlantLower || isPlantUpper) {
            float topMult = float(gl_MultiTexCoord0.t < mc_midTexCoord.t);
            float bottomMult = float(gl_MultiTexCoord0.t > mc_midTexCoord.t);

            // Combine conditions efficiently
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
