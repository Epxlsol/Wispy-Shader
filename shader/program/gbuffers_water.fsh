#include "/lib/all_the_libs.glsl"
uniform sampler2D lightmap;
uniform sampler2D gtexture;
varying vec2 texcoord;
varying vec4 glcolor;
varying vec3 MixedLights;
void main() {
    vec4 Color = texture2D(gtexture, texcoord) * glcolor;
    const vec3 deepBlue = vec3(0.0, 0.04, 0.2025);
    Color.rgb = deepBlue;
    Color.a = 0.22;
    Color.rgb *= MixedLights;
    gl_FragData[0] = Color;
}
