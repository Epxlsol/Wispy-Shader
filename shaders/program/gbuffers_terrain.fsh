#include "/lib/all_the_libs.glsl"

uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;

flat varying float material;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;

    // Ultra-fast gamma
    Color.rgb *= Color.rgb;

    // Direct lighting from vertex shader
    Color.rgb *= MixedLights;

    gl_FragData[0] = Color;
}
