#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;
varying float DepthCenterL;
varying float DepthCenter;
void main() {
    gl_Position = ftransform();
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;

    #ifdef DOF_MANUAL_FOCUS
        DepthCenterL = DOF_FOCUS_DISTANCE;
    #else
        bool IsDH;
        DepthCenter = get_depth(vec2(0.5), IsDH);

        float OldDepth = texelFetch(colortex6, ivec2(0, 0), 0).r;
        float BlendFactor = frameTime / (1 + frameTime) * DOF_FOCUS_ADJUSTMENT_SPEED;
        DepthCenter = mix(OldDepth, DepthCenter, BlendFactor);

        DepthCenterL = ld_exact(DepthCenter, IsDH);
    #endif
}
