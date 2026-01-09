#include "/lib/all_the_libs.glsl"
#include "/global/post/bloom.glsl"

const bool colortex0MipmapEnabled = true;

varying vec2 texcoord;

/* DRAWBUFFERS:1 */

void main() {
    // Fast 3x3 blur with downsampling
    vec3 Color = blur3x3(colortex0, texcoord);
    gl_FragData[0].rgb = Color;
}
