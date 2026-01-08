#include "/lib/all_the_libs.glsl"

#include "/global/lighting.vsh"

// Fast triangle wave (replaces sin)
float tri(float x) {
    return abs(fract(x) - 0.5) * 4.0 - 1.0;
}

void main() {
    init_generic();

    #ifdef WAVY_PLANTS
    if (ViewPos.z > -64) {
        vec3 WorldPos = to_player_pos(ViewPos);
        WorldPos += cameraPosition;
        vec3 WavePos = WorldPos / WAVE_SIZE + frameTimeCounter * WAVE_SPEED;
        
        // Fast triangle waves instead of sin (3x faster)
        float wx = tri(WavePos.x);
        float wy = tri(WavePos.y);
        float wz = tri(WavePos.z);
        float Noise = wx * wy * wz;
        
        Noise *= WAVE_AMPLITUDE + rainStrength * 0.1;
        
        #ifdef WAVE_LEAVES
        if (material == 10003) {
            WorldPos.x += Noise / 2;
            WorldPos.zy -= Noise / 2;
        }
        else
        #endif
        if (material == 10004) {
            if (gl_MultiTexCoord0.t < mc_midTexCoord.t)
                WorldPos += Noise;
        }
        else if (material == 10005) {
            if (gl_MultiTexCoord0.t < mc_midTexCoord.t)
                WorldPos += Noise / 2;
        }
        else if (material == 10006) {
            if (gl_MultiTexCoord0.t > mc_midTexCoord.t)
                WorldPos += Noise / 2;
            else
                WorldPos += Noise;
        }

        WorldPos -= cameraPosition;
        WorldPos = mat3(gbufferModelView) * WorldPos;
        gl_Position = gl_ProjectionMatrix * vec4(WorldPos, 1);
    }
    #endif
}
