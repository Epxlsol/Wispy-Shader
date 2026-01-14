#include "/lib/all_the_libs.glsl"
#include "/global/lighting.vsh"

void main() {
    init_generic();

    #ifdef WAVY_PLANTS

    if (ViewPos.z > -64.0) {

        vec3 RelativeWorldPos = mat3(gbufferModelViewInverse) * ViewPos;
        vec3 WavePos = (RelativeWorldPos + cameraPosition) / WAVE_SIZE + (frameTimeCounter * WAVE_SPEED);

        // Fast Vectorized Sine
        vec3 s = sin(WavePos);
        float Noise = (s.x * s.y * s.z) * (WAVE_AMPLITUDE + rainStrength * 0.1);


        vec3 offset = vec3(0.0);
        bool isTop = gl_MultiTexCoord0.t < mc_midTexCoord.t;

        if (material == 10003.0) { // Leaves
            offset = vec3(Noise * 0.5, -Noise * 0.5, -Noise * 0.5);
        } else if (material >= 10004.0 && material <= 10006.0) {

            float m6Mask = step(10005.5, material);
            float moveMask = float(isTop) + m6Mask * float(!isTop);


            float strengthMult = (material == 10004.0 || (material == 10006.0 && isTop)) ? 1.0 : 0.5;
            offset = vec3(Noise * moveMask * strengthMult);
        }

        ViewPos += mat3(gbufferModelView) * offset;
        gl_Position = gl_ProjectionMatrix * vec4(ViewPos, 1.0);
    }
    #endif

    #if TAA_MODE >= 2
    gl_Position.xy += taaJitter * gl_Position.w;
    #endif
}
