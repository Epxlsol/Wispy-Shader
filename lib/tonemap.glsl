// Ultra-fast approximation
#define to_linear(sRGB) (sRGB * sRGB)

vec3 apply_tonemap(vec3 X) {
    // Simple Reinhard - fastest option
    return X / (1.0 + X);
}

vec3 apply_saturation(vec3 Color, float Sat) {
    float luminance = dot(Color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), Color, Sat);
}

vec3 apply_vibrance(vec3 color, float intensity) {
    float luminance = dot(color, vec3(0.299, 0.587, 0.114));
    return mix(vec3(luminance), color, intensity);
}

vec3 apply_contrast(vec3 color, float contrast) {
    return (color - 0.5) * contrast + 0.5;
}

vec3 mix_preserve_c1lum(vec3 C1, vec3 C2, float Weight) {
    float L1 = dot(C1, vec3(0.299, 0.587, 0.114));
    vec3 CMixed = mix(C1, C2, Weight);
    float L = dot(CMixed, vec3(0.299, 0.587, 0.114)) + 1e-6;
    return CMixed * (L1 / L);
}

vec3 tint_underwater(vec3 FinalColor) {
    if (isEyeInWater == 1) {
        vec3 WaterColor = vec3(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE);
        WaterColor *= WaterColor; // Fast gamma
        WaterColor = mix_preserve_c1lum(WaterColor, fogColor, f_BIOME_WATER_CONTRIBUTION);
        float DistFromSurface = 1 - eyeBrightnessSmooth.y / 240.;
        FinalColor = mix_preserve_c1lum(FinalColor, WaterColor, DistFromSurface);
    }
    return FinalColor;
}
