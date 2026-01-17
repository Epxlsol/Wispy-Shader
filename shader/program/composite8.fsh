#include "/lib/all_the_libs.glsl"
varying vec2 texcoord;
#include "/global/post/taa.glsl"
vec3 motion_blur(vec3 Color, vec2 PrevCoord, vec2 CurrentCoord) {
    #ifdef MOTION_BLUR_LIGHT
    vec2 Velocity = PrevCoord - CurrentCoord;
    vec2 Offset = Velocity / 3.0 * MOTION_BLUR_STRENGTH;
    Offset *= 0.01666 / frameTime;
    vec3 Blur = Color;
    float Noise = bayer8(gl_FragCoord.xy);
    CurrentCoord += Offset * Noise;
    for (int i = 1; i < 3; i++) {
        Blur += texture2D(colortex0, CurrentCoord).rgb;
        CurrentCoord += Offset;
    }
    return Blur / 3.0;
    #else
    vec2 Velocity = PrevCoord - CurrentCoord;
    vec2 Offset = Velocity / 4.0 * MOTION_BLUR_STRENGTH;
    Offset *= 0.01666 / frameTime;
    vec3 Blur = Color;
    float Noise = bayer8(gl_FragCoord.xy);
    CurrentCoord += Offset * Noise;
    for (int i = 1; i < 4; i++) {
        Blur += texture2D(colortex0, CurrentCoord).rgb;
        CurrentCoord += Offset;
    }
    return Blur / 4.0;
    #endif
}
void main() {
    vec4 Color = texture2D(colortex0, texcoord);
    #if TAA_MODE != 0 || defined MOTION_BLUR
    bool IsDH;
    float Depth = get_depth_solid(texcoord, IsDH);
    vec2 PrevCoord = toPrevScreenPos(texcoord, Depth, IsDH);
    #endif
    #ifdef MOTION_BLUR
    if (Depth >= 0.56) {
        Color.rgb = motion_blur(Color.rgb, PrevCoord, texcoord);
    }
    #endif
    #if TAA_MODE != 0
    Color.rgb = TAA(Color.rgb, vec3(texcoord, Depth), PrevCoord, IsDH);
    #endif
    Color.rgb *= EXPOSURE;
    Color.rgb = apply_tonemap(Color.rgb);
    #if TONEMAP_OPERATOR != 3
    #ifdef FAST_GAMMA
    Color.rgb = Color.rgb * Color.rgb;
    #else
    Color.rgb = pow(Color.rgb, vec3(1.0 / 2.2));
    #endif
    #endif
    #ifdef SHARPENING
    ivec2 fragCoord = ivec2(gl_FragCoord.xy);
    vec3 center = Color.rgb;
    vec3 off = (
        texture2D(colortex0, texcoord + vec2(1.0 / viewWidth, 0.0)).rgb +
        texture2D(colortex0, texcoord + vec2(-1.0 / viewWidth, 0.0)).rgb +
        texture2D(colortex0, texcoord + vec2(0.0, 1.0 / viewHeight)).rgb +
        texture2D(colortex0, texcoord + vec2(0.0, -1.0 / viewHeight)).rgb
    ) * 0.25;
    float sharpAmount = SHARPENING * 0.075;
    Color.rgb = center + (center - off) * sharpAmount;
    Color.rgb = clamp(Color.rgb, 0.0, 1.0);
    #endif
    ivec2 finalFragCoord = ivec2(gl_FragCoord.xy);
    #if DEBUG_SHOW_BUFFER == 0
    gl_FragData[0] = vec4(Color.rgb, 1.0);
    #elif DEBUG_SHOW_BUFFER == 1
    gl_FragData[0] = texelFetch2D(colortex1, finalFragCoord, 0);
    #elif DEBUG_SHOW_BUFFER == 2
    gl_FragData[0] = texelFetch2D(noisetex, finalFragCoord, 0);
    #elif DEBUG_SHOW_BUFFER == 3
    gl_FragData[0] = texelFetch2D(depthtex0, finalFragCoord, 0);
    #else
    gl_FragData[0] = texelFetch2D(gaux1, finalFragCoord, 0);
    #endif
}
