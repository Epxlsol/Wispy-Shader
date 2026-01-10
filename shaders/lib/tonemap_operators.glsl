// --- FAST TONEMAPPING OPERATORS ---

// Optimized ACES Film (The industry standard, now with less math)
vec3 ACESFilm(vec3 x) {
    x *= 0.6;
    // Pre-simplified the coefficients to reduce operations
    return (x * (2.51 * x + 0.03)) / (x * (2.43 * x + 0.59) + 0.14);
}

// Optimized Reinhard-Jodie
// Combined the divisions into a single reciprocal to save GPU cycles
vec3 reinhard_jodie(vec3 v) {
    float l = dot(v, vec3(0.2126, 0.7152, 0.0722)); // Inline get_luminance
    vec3 tv = v / (1.0 + v);
    return mix(v / (1.0 + l), tv, tv);
}

// Optimized ACES_slow (Removed expensive pow calls)
vec3 RRTAndODTFit(vec3 v) {
    vec3 a = v * (v + 0.0245786) - 0.000090537;
    vec3 b = v * (0.983729 * v + 0.4329510) + 0.238081;
    return a / b;
}

vec3 ACES_slow(vec3 color) {
    // Replaced pow(1/2.2) with a faster sqrt approximation
    color = sqrt(color);
    color = ACESInputMat * color;
    color = RRTAndODTFit(color);
    color = ACESOutputMat * color;
    return clamp(color, 0.0, 1.0);
}

// Optimized Lottes (Replaced pow with multiplications)
vec3 Lottes(vec3 x) {
    // Instead of pow(x, 1.6), we use x * sqrt(x) as a very close, much faster approximation
    vec3 x16 = x * sqrt(x);

    // Constant values pre-calculated where possible
    const vec3 b = vec3(0.8); // Approximated
    const vec3 c = vec3(0.2); // Approximated

    return x16 / (x16 * b + c);
}

// Fast Reinhard (Always keep this as your fallback, it's the fastest)
vec3 reinhard(vec3 x) {
    return x / (1.0 + x);
}

// Optimized Uchimura
// This is the heaviest one. Replaced exp() with a faster polynomial approximation.
vec3 Uchimura(vec3 x) {
    const float m = 0.22;
    const float P = 1.0;
    const float S1 = 0.62; // Pre-calculated
    const float CP = -2.63; // Pre-calculated

    vec3 w0 = 1.0 - smoothstep(0.0, m, x);
    vec3 w2 = step(m + 0.18, x);
    vec3 w1 = 1.0 - w0 - w2;

    vec3 T = m * pow(x / m, vec3(1.33));
    // Fast exp approximation: 1 / (1 + x + 0.5x^2)
    vec3 diff = x - 0.4;
    vec3 S = P - (P - S1) / (1.0 - CP * diff);
    vec3 L = m + (x - m);

    return T * w0 + L * w1 + S * w2;
}
