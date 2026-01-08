#include "/lib/all_the_libs.glsl"

varying vec2 texcoord;

/* DRAWBUFFERS:0 */

void main() {
    gl_FragData[0] = texture2D(colortex0, texcoord);
}
