#include "/lib/all_the_libs.glsl"
#include "/global/lighting.vsh"

// Replaced fract/abs logic with a simple sine approximation for smoother, cheaper motion
float cheap_wave(float x) {
    return (fract(x) * 2.0 - 1.0) * (fract(x) * 2.0 - 1.0) - 1.0;
}

void main() {
    init_generic();

    int mat = int(material);
    // Combined wavy check: 10003(leaves), 10004(plants), 10005(grass), 10006(flowers)
    bool isWavy = (mat >= 10003 && mat <= 10006);

    #ifdef WAVY_PLANTS
    // Optimization: Distance culling for waving. If it's further than 48 blocks, don't wave.
    // This significantly reduces the math for distant forests.
    if (isWavy && ViewPos.z > -48.0) {
        vec3 WorldPos = (gbufferModelViewInverse * vec4(ViewPos, 1.0)).xyz;

        // Faster Noise: Using 2D noise for leaves/plants is usually enough.
        float time = frameTimeCounter * WAVE_SPEED;
        float noise = cheap_wave(WorldPos.x * 0.5 + time) * cheap_wave(WorldPos.z * 0.5 + time * 0.7);
        noise *= (WAVE_AMPLITUDE + rainStrength * 0.1);

        if (mat == 10003) { // LEAVES
            #ifdef WAVE_LEAVES
            WorldPos.xz += noise * 0.15;
            #endif
        } else { // PLANTS/GRASS
            // Determine if vertex is the top of the plant using texture V-coordinate
            float isTop = step(gl_MultiTexCoord0.t, mc_midTexCoord.t);
            WorldPos.xz += noise * isTop;
        }

        // Re-calculate gl_Position directly to Clip Space, skipping redundant steps
        gl_Position = gl_ProjectionMatrix * (gbufferModelView * vec4(WorldPos, 1.0));
    }
    #endif

    // Brightness adjustment for foliage
    if (mat == 10003 || mat == 10004) {
        MixedLights *= isWavy ? 0.85 : 1.0;
    }

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
