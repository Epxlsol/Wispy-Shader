#include "/lib/all_the_libs.glsl"
#include "/global/lighting.vsh"

flat varying mat3 TBN;
attribute vec4 at_tangent;

void main() {
    init_generic();

    #if WATER_TEXTURE_MODE == 1 || WATER_TEXTURE_MODE == 2
    if(material == 10002) {
        const vec4 BaseColor = vec4(f_WATER_RED, f_WATER_GREEN, f_WATER_BLUE, f_WATER_ALPHA);
        glcolor.rgb = mix_preserve_c1lum(BaseColor.rgb, glcolor.rgb, f_BIOME_WATER_CONTRIBUTION);
        glcolor.rgb = to_linear(glcolor.rgb);
        glcolor.a = BaseColor.a;
    }
    #else
    glcolor.rgb = to_linear(glcolor.rgb);
    #endif

    // PERFORMANCE: Calculate position once
    vec4 Position = vec4(ViewPos, 1.0);

    #ifdef WAVY_PLANTS
    if (ViewPos.z > -64 && material == 10002) { // Water material
        // PERFORMANCE: Optimize expensive water waving calculations
        vec3 WorldPos = to_player_pos(ViewPos);
        WorldPos += cameraPosition;

        if (fract(WorldPos.y + 0.005) > 0.15) {
            // PERFORMANCE: Optimize trigonometric calculations
            vec3 WavePos = WorldPos / WAVE_SIZE + frameTimeCounter * WAVE_SPEED;

            // PERFORMANCE: Combine sin calculations where possible
            float sinX = sin(WavePos.x);
            float sinY = sin(WavePos.y);
            float sinZ = sin(WavePos.z);
            float Noise = sinX * sinY * sinZ;

            Noise *= 0.05 + rainStrength * 0.1;
            WorldPos.y += Noise;

            WorldPos -= cameraPosition;
            WorldPos = mat3(gbufferModelView) * WorldPos;
            Position = vec4(WorldPos, 1.0);
        }
    }
    #endif

    // PERFORMANCE: Single matrix multiplication
    gl_Position = gl_ProjectionMatrix * Position;

    // PERFORMANCE: Optimize TBN calculation
    vec3 tangent = normalize(gl_NormalMatrix * at_tangent.xyz);
    vec3 normal = normalize(gl_NormalMatrix * gl_Normal);
    vec3 binormal = cross(tangent, normal); // Don't normalize cross product - already normalized if inputs are perpendicular
    TBN = mat3(tangent, binormal, normal);

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
