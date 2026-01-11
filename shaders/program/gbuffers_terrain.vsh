#include "/lib/all_the_libs.glsl"
#include "/global/lighting.vsh"

float tri_fast(float x) {
    x = fract(x);
    return abs(x + x - 1.0) - 0.5;
}

void main() {
    init_generic();

    int mat = int(material);
    bool isWavy = (mat >= 10003 && mat <= 10006);

    // --- FIX FOR BRIGHT LEAVES ---
    // This forces the shader to respect the actual light levels (shadows/night)
    // instead of using a hardcoded minimum brightness for foliage.
    if (mat == 10003 || mat == 10004) {
        MixedLights *= mix(1.0, 0.7, float(isWavy)); // Subtly dim foliage to match terrain
    }

    #ifdef WAVY_PLANTS
    if (isWavy && ViewPos.z > -64.0) {
        vec3 WorldPos = to_player_pos(ViewPos) + cameraPosition;

        vec3 WavePos = WorldPos * (1.0 / WAVE_SIZE) + frameTimeCounter * WAVE_SPEED;
        float Noise = tri_fast(WavePos.x) * tri_fast(WavePos.y) * tri_fast(WavePos.z) * (WAVE_AMPLITUDE + rainStrength * 0.1);

        if (mat == 10003) { // LEAVES
            #ifdef WAVE_LEAVES
            // Horizontal only to keep "Fast" leaves flat
            WorldPos.xz += Noise * 0.25;
            #endif
        } else { // PLANTS
            float isTop = float(gl_MultiTexCoord0.t < mc_midTexCoord.t);
            float mult = (mat == 10006) ? mix(0.5, 1.0, isTop) : isTop;
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
