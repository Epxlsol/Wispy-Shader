#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;
varying float DepthCenterL;
varying float DepthCenter;

/* DRAWBUFFERS:06 */
const bool colortex0MipmapEnabled = true;

float calc_CoC(float Depth, float DepthCenter) {
    float focalLength = DepthCenter / (DepthCenter + 1);
    float CoC = abs(DOF_APERTURE_SIZE * (focalLength * (Depth - DepthCenter)) /
          (Depth * (DepthCenter - focalLength)));
    return CoC;
}

// Reduced samples for performance (16 instead of 32)
const vec2 vogel_disk[16] = vec2[](
    vec2(0.12064426510477419, 0.015554431411765695),
    vec2(-0.16400077998918963, 0.16180237012184204),
    vec2(0.020080498035937415, -0.2628838391620438),
    vec2(0.19686650437195816, 0.27801320993574674),
    vec2(-0.37362329188851157, -0.049763799980476156),
    vec2(0.34544673107582735, -0.20696126421568928),
    vec2(-0.12135781397691386, 0.4507963336805642),
    vec2(-0.22749138875333694, -0.41407969197383454),
    vec2(0.4797593802468298, 0.19235249500691445),
    vec2(-0.5079968434096749, 0.22345015963708734),
    vec2(0.23843255951864029, -0.5032700515259672),
    vec2(0.17505863904522073, 0.587555727235086),
    vec2(-0.5451127409909945, -0.2978253068585009),
    vec2(0.6300137885218894, -0.12390992876509886),
    vec2(-0.391501580064061, 0.5662295575692019),
    vec2(-0.09379538975841809, -0.6746452122696498)
);

vec3 blur_dof(vec2 texcoord, float CoC) {
    vec3 Sum = vec3(0);
    CoC *= gbufferProjection[1][1] / 1.37;
    vec2 Radius = resolutionInv * CoC;
    
    int samples = min(DOF_BLUR_QUALITY, 16);
    for(int i = 0; i < samples; i++) {
        vec2 Offset = vogel_disk[i] * Radius;
        float lod = log2(CoC * 0.5);
        Sum += texture2DLod(colortex0, texcoord + Offset, lod).rgb;
    }
    
    return Sum / float(samples);
}

void main() {
    bool IsDH;
    float Depth = get_depth(texcoord, IsDH);
    float DepthL = ld_exact(Depth, IsDH);
    
    float CoC = calc_CoC(DepthL, DepthCenterL);
    CoC = Depth < 0.56 ? min(10, CoC) : min(25, CoC);
    
    vec4 Color = vec4(blur_dof(texcoord, CoC), 1);
    
    #ifdef DOF_SHOW_FOCUS
        if(!hideGUI)
            Color.g += float(abs(DepthL - DepthCenterL) < 0.2);
    #endif
    
    gl_FragData[0] = Color;
    
    if(all(lessThan(gl_FragCoord.xy, vec2(1)))) {
        gl_FragData[1].r = DepthCenter;
    }
}
