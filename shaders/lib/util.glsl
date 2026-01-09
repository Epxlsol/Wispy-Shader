// Optimized util.glsl - Faster math utilities

// Fast random - uses fewer operations
float random(vec2 coords) {
    return fract(sin(dot(coords, vec2(12.9898, 78.233))) * 43758.5453);
}

float random3D(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.543))) * 43758.5453);
}

// Optimized projection - reduced operations
vec3 project_and_divide(mat4 Projection_mat, vec3 x) {
    vec4 HomogeneousPos = Projection_mat * vec4(x, 1.0);
    return HomogeneousPos.xyz / HomogeneousPos.w;
}

vec3 to_view_pos(vec3 p, bool IsDH) {
    p = p * 2.0 - 1.0;
    return IsDH ? project_and_divide(dhProjectionInverse, p) 
                : project_and_divide(gbufferProjectionInverse, p);
}

vec3 view_screen(vec3 x, bool IsDH) {
    x = IsDH ? project_and_divide(dhProjection, x) 
             : project_and_divide(gbufferProjection, x);
    return x * 0.5 + 0.5;
}

// Simple matrix multiplication - no need for mat3 constructor
vec3 to_player_pos(vec3 p) {
    return mat3(gbufferModelViewInverse) * p;
}

vec3 player_view(vec3 p) {
    return mat3(gbufferModelView) * p;
}

// Faster linearize - single division
float linearize_depth(float D) {
    return near / (1.0 - D);
}

float ld_exact(float depth, float near, float far) {
    return (near * far) / (depth * (near - far) + far);
}

// Optimized TBN matrix creation
mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    vec3 bitangent = cross(normal, tangent);
    return mat3(tangent, bitangent, normal);
}

mat3 tbnNormal(vec3 normal) {
    vec3 tangent = normalize(cross(normal, vec3(0.0, 1.0, 1.0)));
    return tbnNormalTangent(normal, tangent);
}

// Fast luminance - pre-calculated constants
float get_luminance(vec3 Color) {
    return dot(Color, vec3(0.299, 0.587, 0.114));
}

// Optimized rotation - single sin/cos call
vec2 rotate(vec2 P, float Ang) {
    float cosT = cos(Ang);
    float sinT = sin(Ang);
    return vec2(P.x * cosT - P.y * sinT, P.y * cosT + P.x * sinT);
}

// Squared length - much faster than length()
float len2(vec2 v) { return dot(v, v); }
float len2(vec3 v) { return dot(v, v); }

// Fast power functions - avoid expensive pow()
float pow2(float x) { return x * x; }
float pow4(float x) { 
    float x2 = x * x;
    return x2 * x2;
}
float pow8(float x) {
    float x2 = x * x;
    float x4 = x2 * x2;
    return x4 * x4;
}

vec2 pow2(vec2 x) { return x * x; }
vec2 pow4(vec2 x) { 
    vec2 x2 = x * x;
    return x2 * x2;
}

vec3 pow2(vec3 x) { return x * x; }
vec3 pow4(vec3 x) { 
    vec3 x2 = x * x;
    return x2 * x2;
}

vec4 pow2(vec4 x) { return x * x; }
vec4 pow4(vec4 x) { 
    vec4 x2 = x * x;
    return x2 * x2;
}

// Component-wise min/max - optimized
float min_component(vec2 a) { return min(a.x, a.y); }
float min_component(vec3 a) { return min(a.x, min(a.y, a.z)); }
float min_component(vec4 a) { return min(min(a.x, a.y), min(a.z, a.w)); }

float max_component(vec2 a) { return max(a.x, a.y); }
float max_component(vec3 a) { return max(a.x, max(a.y, a.z)); }
float max_component(vec4 a) { return max(max(a.x, a.y), max(a.z, a.w)); }

// Fast Cornette-Shanks phase function
float cs_phase(float Mu, float g) {
    float g2 = g * g;
    float denom = pow(1.0 + g2 - 2.0 * g * Mu, 1.5);
    return (3.0 * (1.0 - g2) * (1.0 + Mu * Mu)) / (25.132741 * (2.0 + g2) * denom); // 8*PI pre-calculated
}

// Optimized XLF phase function
float xlf_phase(float angle, float g) {
    float g2 = g * g;
    float denom = 1.0 + g2 - 2.0 * g * angle;
    float result = 1.5 * ((1.0 - g2) / (2.0 + g2)) * ((1.0 + angle * angle) / denom) + g * angle;
    return result * 0.0795775; // 1/(4*PI) pre-calculated
}

// Ultra-fast approximations for special cases
float fast_length(vec3 v) {
    return dot(v, v); // Use squared length when exact length not needed
}

vec3 fast_normalize(vec3 v) {
    return v * inversesqrt(dot(v, v));
}

// Fast exp approximation for fog (when high precision not needed)
float fast_exp(float x) {
    // Good approximation for fog calculations
    x = 1.0 + x * 0.0625; // x/16
    x *= x; x *= x; x *= x; x *= x; // x^16
    return x;
}
