#include "/lib/all_the_libs.glsl"

uniform sampler2D lightmap;
uniform sampler2D gtexture;

varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;

/* DRAWBUFFERS:0 */

void main() {
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;

    vec3 deepBlue = vec3(0.0, 0.2, 0.45);

    Color.rgb = mix(Color.rgb, deepBlue, 1);

    Color.a = 0.22;

    // 4. Final Lighting
    Color.rgb *= Color.rgb;
    Color.rgb *= MixedLights;

    gl_FragData[0] = Color;
}
