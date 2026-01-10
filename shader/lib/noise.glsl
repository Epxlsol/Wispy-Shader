// Optimized noise functions - reduced texture samples

// Single octave noise - fast
float noise(vec2 Coords) {
    float invRes = 1.0 / (noiseTextureResolution * 0.5);
    return texture2D(noisetex, Coords * invRes).x;
}

// Two octave noise normal - optimized
vec2 noise_normal(vec2 Coords) {
    float invRes1 = 1.0 / (noiseTextureResolution * 0.5);
    float invRes2 = 1.0 / (noiseTextureResolution * 1.0);
    
    vec2 color = (texture2D(noisetex, Coords * invRes1).yz * 2.0 - 1.0) * 0.3;
    color += (texture2D(noisetex, Coords * invRes2).yz * 2.0 - 1.0) * 0.5;
    return color;
}

// Optimized single-sample water normals for performance
vec2 noise_water(vec2 Coords) {
    #ifdef WATER_NORMALS
    Coords /= WATER_NORMAL_SIZE;
    vec2 offset = frameTimeCounter * WATER_NORMAL_SPEED * 0.2;
    // Single texture lookup instead of 2
    return (texture2D(noisetex, (Coords + offset) / 32.0).yz * 2.0 - 1.0) * 0.15 * WATER_NORMAL_STRENGTH;
    #else
    return vec2(0.0);
    #endif
}

// Optimized FBM for clouds - reduced iterations
float fbm_clouds(vec2 x, int detail) {
    float v = 0.0;
    float a = 0.5;
    vec2 shift = vec2(100.0);
    
    // Pre-calculated rotation matrix
    const mat2 rot = mat2(0.8775826, 0.479426, -0.479426, 0.8775826); // cos(0.5), sin(0.5)
    
    for (int i = 0; i < detail; ++i) {
        v += a * noise(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Cloud normal FBM
vec2 fbm_clouds_normal(vec2 x, int detail) {
    vec2 v = vec2(0.0);
    float a = 0.5;
    vec2 shift = vec2(100.0);
    
    const mat2 rot = mat2(0.8775826, 0.479426, -0.479426, 0.8775826);
    
    for (int i = 0; i < detail; ++i) {
        v += a * noise_normal(x);
        x = rot * x * 2.0 + shift;
        a *= 0.5;
    }
    return v;
}

// Fast FBM without rotation (faster but less quality)
float fbm_fast(vec2 x, int detail) {
    float v = 0.0;
    float a = 0.5;
    float invRes = 1.0 / noiseTextureResolution;
    
    for (int i = 0; i < detail; ++i) {
        v += a * texture2D(noisetex, x * invRes).x;
        x *= 2.0;
        a *= 0.5;
    }
    return v;
}

// Optimized 8x8 Bayer matrix dithering
float bayer8(vec2 a) {
    uvec2 b = uvec2(a);
    uint c = (b.x ^ b.y) << 1u;
    return float(
        ((c & 8u | b.y & 4u) >> 2u) |
        ((c & 4u | b.y & 2u) << 1u) |
        ((c & 2u | b.y & 1u) << 4u)
    ) / 64.0; // Pre-divided constant
}

// Interleaved gradient noise - fast temporal dither
float ign(vec2 Pos, const bool Animate) {
    if (Animate) {
        float FrameMod = float(frameCounter % 64);
        Pos += 5.588238 * FrameMod;
    }
    return fract(52.9829189 * fract(0.06711056 * Pos.x + 0.00583715 * Pos.y));
}

// Main dither function
float dither(vec2 Pos) {
    #if TAA_MODE != 0
    return ign(Pos, true);
    #else
    return bayer8(Pos);
    #endif
}
