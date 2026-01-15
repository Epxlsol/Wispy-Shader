#include "/lib/all_the_libs.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;

    // Optimized: Single hardcoded color
    const vec3 deepBlue = vec3(0.0, 0.04, 0.2025);
    Color.rgb = deepBlue;
    Color.a = 0.22;

    // Fused gamma + lighting
    Color.rgb *= MixedLights;

    gl_FragData[0] = Color;
}
