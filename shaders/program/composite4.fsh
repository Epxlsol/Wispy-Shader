#include "/lib/all_the_libs.glsl"
#include "/global/post/bloom.glsl"

varying vec2 texcoord;
varying vec2 PrevTilePos;

/* DRAWBUFFERS:1 */

void main() {
    vec3 Color = blur3x3(colortex1, PrevTilePos);
    gl_FragData[0].rgb = Color;
}
