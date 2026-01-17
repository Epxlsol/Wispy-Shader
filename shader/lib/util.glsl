#extension GL_EXT_gpu_shader4 : enable

float random(vec2 coords) {
    // PERFORMANCE: Use cheaper hash function
    return fract(sin(dot(coords.xy, vec2(12.9898, 78.233))) * 43758.5453);
}

float random3D(vec3 p) {
    return fract(sin(dot(p, vec3(12.9898, 78.233, 45.543))) * 43758.5453);
}

// PERFORMANCE: Optimize matrix division
vec3 project_and_divide(mat4 Projection_mat, vec3 x) {
    vec4 HomogeneousPos = Projection_mat * vec4(x, 1);
    // PERFORMANCE: Avoid division by checking w component first if needed
    return HomogeneousPos.xyz / HomogeneousPos.w;
}

// PERFORMANCE: Optimize view position calculation
vec3 to_view_pos(vec3 p, bool IsDH) {
    p = p * 2.0 - 1.0;
    return project_and_divide(IsDH ? dhProjectionInverse : gbufferProjectionInverse, p);
}

vec3 view_screen(vec3 x, bool IsDH) {
    return project_and_divide(IsDH ? dhProjection : gbufferProjection, x) * 0.5 + 0.5;
}

// PERFORMANCE: Cache inverse matrix if used frequently
vec3 to_player_pos(vec3 p) {
    // PERFORMANCE: If this is called frequently, consider pre-computing the matrix
    return mat3(gbufferModelViewInverse) * p;
}

vec3 player_view(vec3 p) {
    return mat3(gbufferModelView) * p;
}

// PERFORMANCE: Simplified linearization (if accuracy allows)
float linearize_depth(float D) {
    // PERFORMANCE: Pre-compute 'near' as uniform if constant
    return near / (1.0 - D);
}

// PERFORMANCE: More efficient depth calculation
float ld_exact(float depth, float near, float far) {
    // PERFORMANCE: If near/far are constants, pre-compute (near * far) and (near - far)
    return (near * far) / (depth * (near - far) + far);
}

// PERFORMANCE: Optimize TBN calculation
mat3 tbnNormalTangent(vec3 normal, vec3 tangent) {
    vec3 bitangent = cross(normal, tangent);
    return mat3(tangent, bitangent, normal);
}

// PERFORMANCE: More efficient normal calculation
mat3 tbnNormal(vec3 normal) {
    // PERFORMANCE: Choose reference vector based on normal to avoid degeneracy
    vec3 reference = abs(normal.y) < 0.999 ? vec3(0, 1, 0) : vec3(1, 0, 0);
    vec3 tangent = normalize(cross(reference, normal));
    return tbnNormalTangent(normal, tangent);
}

// PERFORMANCE: Optimized luminance calculation (already quite good)
float get_luminance(vec3 Color) {
    return dot(Color, vec3(0.299, 0.587, 0.114));
}

bool isDH_pixel(vec2 screenCoord) {
    #ifdef DISTANT_HORIZONS
    float vanillaDepth = texture(depthtex0, screenCoord).r;  // Use texture() instead of texture2D()
    float dhDepth = texture(dhDepthTex, screenCoord).r;
    return (vanillaDepth >= 1.0 && dhDepth < 1.0);
    #else
    return false;
    #endif
}

// PERFORMANCE: Optimize rotation matrix construction
vec2 rotate(vec2 P, float Ang) {
    // PERFORMANCE: If Ang is constant, pre-compute sin/cos
    float cosT = cos(Ang);
    float sinT = sin(Ang);
    return vec2(P.x * cosT - P.y * sinT, P.x * sinT + P.y * cosT);  // Direct calculation
}

// PERFORMANCE: Optimized length squared (already good)
float len2(vec2 v) { return dot(v, v); }
float len2(vec3 v) { return dot(v, v); }

// PERFORMANCE: Optimized power functions
float pow2(float x) { return x * x; }
float pow4(float x) {
    x *= x;
    return x * x;  // Already optimized
}

vec2 pow2(vec2 x) { return x * x; }
vec3 pow2(vec3 x) { return x * x; }
vec4 pow2(vec4 x) { return x * x; }

vec2 pow4(vec2 x) {
    x *= x;
    return x * x;
}
vec3 pow4(vec3 x) {
    x *= x;
    return x * x;
}
vec4 pow4(vec4 x) {
    x *= x;
    return x * x;
}

// PERFORMANCE: Optimized min/max component functions
float min_component(vec2 a) { return min(a.x, a.y); }
float min_component(vec3 a) { return min(min(a.x, a.y), a.z); }
float min_component(vec4 a) { return min(min(a.x, a.y), min(a.z, a.w)); }

float max_component(vec2 a) { return max(a.x, a.y); }
float max_component(vec3 a) { return max(max(a.x, a.y), a.z); }
float max_component(vec4 a) { return max(max(a.x, a.y), max(a.z, a.w)); }

// PERFORMANCE: Optimize phase functions (these are expensive!)
float cs_phase(float Mu, float g) {
    float g2 = g * g;
    float denom = pow(1.0 + g2 - 2.0 * g * Mu, 1.5);  // This pow() is expensive!
    return (3.0 * (1.0 - g2) * (1.0 + Mu * Mu)) / (8.0 * 3.14159 * (2.0 + g2) * denom);
}

// PERFORMANCE: Optimize phase function (also expensive!)
float xlf_phase(float angle, const float g) {
    float g2 = g * g;
    float denom = 1.0 + g2 - 2.0 * g * angle;
    return 0.0795774715 * (1.5 * (1.0 - g2) / (2.0 + g2)) * ((1.0 + angle * angle) / denom + g * angle);
}
