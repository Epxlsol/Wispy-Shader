#ifdef DISTANT_HORIZONS
#define furthest dhFarPlane
#else
#define furthest far
#endif

// Faster noise using linear approximation instead of exp()
vec3 dh_noise(vec3 PlayerPos, vec3 Color) {
    vec3 WorldPos = PlayerPos + cameraPosition + gbufferModelViewInverse[3].xyz;
    vec3 NoisePos = floor(WorldPos * DH_NOISE_SIZE + 0.001) / DH_NOISE_SIZE;

    // random3D should be in your util.glsl
    float rnd = random3D(NoisePos);
    Color *= (1.104 - rnd * 0.25);

    return Color;
}

// Fixed the boolean "!" error for GLSL 1.20
bool transition_to_dh(vec3 PlayerPos, const bool IsDHPass, float Dither) {
    float Bias = (IsDHPass ? 1.0 : 0.0) * (far * 0.03125); // 1/32 = 0.03125
    float Fade = (IsDHPass ? 0.0 : 1.0) * Dither * 8.0;
    return length(PlayerPos) > (far - DH_CUTOFF - Bias + Fade);
}

float ld_exact(float depth, bool IsDH) {
    float n = IsDH ? dhNearPlane : near;
    float f = IsDH ? dhFarPlane : far;
    return (n * f) / (depth * (n - f) + f);
}

float get_depth(vec2 ScreenPos, out bool IsDH) {
    float Depth = texture2D(depthtex0, ScreenPos).x;
    IsDH = false;

    #ifdef DISTANT_HORIZONS
    if (Depth >= 1.0) {
        Depth = texture2D(dhDepthTex, ScreenPos).x;
        IsDH = (Depth < 1.0);
    }
    #endif

    #ifdef MC_GL_RENDERER_RADEON
    if(Depth <= 0.0) Depth = 1.0;
    #endif

    return Depth;
}
